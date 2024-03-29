//
//  HourlyStepData.swift
//  myPedometer
//
//  Created by Sam Roman on 1/25/24.
//

import Foundation

struct HourlySteps: Identifiable, Equatable {
    let id = UUID()
    let hour: Int
    let steps: Int
}
