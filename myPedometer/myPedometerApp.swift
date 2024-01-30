//
//  myPedometerApp.swift
//  myPedometer
//
//  Created by Sam Roman on 1/24/24.
//

import SwiftUI
import SwiftData

@main
struct myPedometerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        let context = persistenceController.container.viewContext
        let dataStore = PedometerDataStore(context: context)
        
        let pedometerDataProvider: PedometerDataProvider & PedometerDataObservable
        
#if targetEnvironment(simulator)
        pedometerDataProvider = MockPedometerDataProvider(context: context)
#else
        pedometerDataProvider = PedometerManager(context: context, dataStore: dataStore)
#endif
        
        return WindowGroup {
            ContentView(pedometerDataProvider: pedometerDataProvider)
                .environment(\.managedObjectContext, context)
                .environmentObject(dataStore)
        }
    }
}
