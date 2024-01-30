//
//  StepDataViewModel.swift
//  myPedometer
//
//  Created by Sam Roman on 1/24/24.
//

import Foundation
import CoreMotion

class StepDataViewModel: ObservableObject {
    // Published properties to be observed by HomeView
    @Published var stepDataList: [DailyLog] = []
    @Published var hourlyAverageSteps: [HourlySteps] = []
    @Published var weeklyAverageSteps: Int = 0
    @Published var todayLog: DailyLog?
    @Published var dailyGoal: Int
    
    // The pedometer data provider (either real or mock)
    var pedometerDataProvider: PedometerDataProvider & PedometerDataObservable
    
    // Initializer
    init(pedometerDataProvider: PedometerDataProvider & PedometerDataObservable) {
        self.pedometerDataProvider = pedometerDataProvider
        
        // Retrieve and set the daily goal
        self.dailyGoal = UserDefaultsHandler.shared.retrieveDailyGoal() ?? 0
        
        //Retrieve step data from provider
        pedometerDataProvider.loadStepData { logs, hours in
            self.stepDataList = logs
            self.hourlyAverageSteps = hours
            self.calculateWeeklySteps()
        }
    }
    
    //Calculate weekly average steps
    private func calculateWeeklySteps() {
        let totalSteps = stepDataList.reduce(0) { $0 + Int($1.totalSteps) }
        let averageSteps = totalSteps / max(stepDataList.count, 1)
        self.weeklyAverageSteps = averageSteps
    }
    
    //Check if log falls in today
    func isToday(log: DailyLog) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(log.date ?? Date())
    }
    
    
}
