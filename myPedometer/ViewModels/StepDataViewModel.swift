//
//  StepDataViewModel.swift
//  myPedometer
//
//  Created by Sam Roman on 1/24/24.
//

import Foundation
import CoreMotion
import Combine

class StepDataViewModel: ObservableObject {
    
    private var userSettingsManager: UserSettingsManager
    
    //Today View
    @Published var todayLog: DailyLog?
    @Published var dailyStepGoal: Int
    @Published var caloriesBurned: Double = 0
    @Published var todaySteps: Int = 0
    @Published var dailyCalGoal: Int
    
    // Week View
    @Published var stepDataList: [DailyLog] = []
    @Published var hourlyAverageSteps: [HourlySteps] = []
    @Published var weeklyAverageSteps: Int = 0
    
    
    //Awards View
    @Published var lifeTimeSteps: Int = 0
    @Published var personalBestDate: String = ""
    @Published var stepsRecord: Int = 0
    @Published var calRecord: Int = 0
    
    //Steps
    @Published var threeKStepsReached: Bool = false
    @Published var fiveKStepsReached: Bool = false
    @Published var tenKStepsReached: Bool = false
    @Published var twentyKStepsReached: Bool = false
    @Published var thirtyKStepsReached: Bool = false
    @Published var fortyKStepsReached: Bool = false
    @Published var fiftyKStepsReached: Bool = false
    
    //Calories
    @Published var fiveHundredCalsReached: Bool = false
    @Published var thousandCalsReached: Bool = false
        
    @Published var error: UserFriendlyError?
    
    
    private var cancellables = Set<AnyCancellable>()
    
    // The pedometer data provider (either real or mock)
    var pedometerDataProvider: PedometerDataProvider & PedometerDataObservable
    
    // Initializer
    init(pedometerDataProvider: PedometerDataProvider & PedometerDataObservable, userSettingsManager: UserSettingsManager) {
        self.userSettingsManager = userSettingsManager
        self.pedometerDataProvider = pedometerDataProvider
        
        //Retrieve and set the daily goal
        self.dailyStepGoal = userSettingsManager.dailyStepGoal
        self.dailyCalGoal = userSettingsManager.dailyCalGoal
        
        //Retrieve step data from provider
        loadData(provider: pedometerDataProvider)
        
        //Error subscription
        self.pedometerDataProvider.errorPublisher
            .compactMap { $0 } // Filter out nil errors
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
        
        //Today supscription
        pedometerDataProvider.todayLogPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                
                if let todayLog = value, strongSelf.isToday(log: todayLog) {
                    strongSelf.todayLog = todayLog
                    strongSelf.todaySteps = Int(todayLog.totalSteps)
                    strongSelf.calculateCaloriesBurned()
                    self?.updateDailyLogWith(todayLog: todayLog)
                }
            }
            .store(in: &cancellables)
        
        //Subscribe to user variables
        userSettingsManager.$dailyStepGoal
            .receive(on: DispatchQueue.main)
            .assign(to: \.dailyStepGoal, on: self)
            .store(in: &cancellables)
        
        userSettingsManager.$dailyCalGoal
            .receive(on: DispatchQueue.main)
            .assign(to: \.dailyCalGoal, on: self)
            .store(in: &cancellables)
        
        userSettingsManager.$stepsRecord
            .receive(on: DispatchQueue.main)
            .assign(to: \.stepsRecord, on: self)
            .store(in: &cancellables)
        
        userSettingsManager.$calorieRecord
            .receive(on: DispatchQueue.main)
            .assign(to: \.calRecord, on: self)
            .store(in: &cancellables)
        
        userSettingsManager.$lifetimeSteps
            .receive(on: DispatchQueue.main)
            .assign(to: \.lifeTimeSteps, on: self)
            .store(in: &cancellables)
    }
    
    // Error Handler
    private func handleError(_ error: Error) {
        self.error = UserFriendlyError(error: error) // Pass the error to the view model
    }
    
    //Load initial data
    func loadData(provider: PedometerDataProvider & PedometerDataObservable) {
        pedometerDataProvider.loadStepData { logs, hours, error in
            if let error = error {
                self.handleError(error)
            }
            DispatchQueue.main.async {
                self.stepDataList = logs
                self.calculateCaloriesBurned()
                self.calculateWeeklySteps()
            }
        }
    }
    
    // Calculate weekly average steps
    func calculateWeeklySteps() {
        let totalSteps = stepDataList.reduce(0) { $0 + Int($1.totalSteps) }
        let averageSteps = totalSteps / max(stepDataList.count, 1)
        self.weeklyAverageSteps = averageSteps
    }
    
    // Calculate approximate calories burned
    func calculateCaloriesBurned() {
        self.caloriesBurned = Double(todaySteps) * 0.04
    }
    
    // Check if log falls in today
    func isToday(log: DailyLog) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(log.date ?? Date())
    }
    
    private func updateDailyLogWith(todayLog: DailyLog) {
        // Update today's log and calculate calories burned
        self.todayLog = todayLog
        self.todaySteps = Int(todayLog.totalSteps)
        self.calculateCaloriesBurned()
        
        // Update User settings with new daily log and steps
        userSettingsManager.updateDailyLog(with: todaySteps, calories: Int(caloriesBurned), date: Date())
        userSettingsManager.updateUserLifetimeSteps(additionalSteps: todaySteps)
        userSettingsManager.checkAndUpdatePersonalBest(with: todaySteps, calories: Int(caloriesBurned))
        
        //TODO: Update any active challenges with dailylog steps here
    }
}
