//
//  PedometerManager.swift
//  myPedometer
//
//  Created by Sam Roman on 1/24/24.
//

import Foundation
import CoreMotion
import CoreData

protocol PedometerDataProvider {
    func fetchSteps(for date: Date, completion: @escaping (Int, Error?) -> Void)
}

class PedometerManager: ObservableObject, PedometerDataProvider {
    let pedometer = CMPedometer()
    var dateManager: DateManager
    private var context: NSManagedObjectContext
    var startOfDay = Date()
    
    init(context: NSManagedObjectContext, dateManager: DateManager){
        self.context = context
        self.dateManager = dateManager
        startOfDay = Calendar.current.startOfDay(for: dateManager.selectedDate)
    }
    
    func startPedometerUpdates(updateHandler: @escaping (Int) -> Void) {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: startOfDay) { data, error in
                guard let data = data, error == nil else { return }
                updateHandler(data.numberOfSteps.intValue)
            }
        } else {
            // Step counting is not available on this device
        }
    }
    
    func fetchSteps(for date: Date, completion: @escaping (Int, Error?) -> Void) {
           guard CMPedometer.isStepCountingAvailable() else {
               completion(0, NSError(domain: "CMPedometer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Step counting not available."]))
               return
           }

           let startOfDay = Calendar.current.startOfDay(for: date)
           let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

           pedometer.queryPedometerData(from: startOfDay, to: endOfDay) { data, error in
               if let error = error {
                   completion(0, error)
                   return
               }
               let stepCount = data?.numberOfSteps.intValue ?? 0
               completion(stepCount, nil)
           }
       }
    
}
