//
//  ChallengeDetails.swift
//  myPedometer
//
//  Created by Sam Roman on 3/18/24.
//

import Foundation
import CloudKit

struct ChallengeDetails {
    var startTime: Date
    var endTime: Date
    var goalSteps: Int32
    var active: Bool
    var participants: [Participant]
    var recordId: String
}
extension ChallengeDetails {
    
    static func fromCKRecord(_ record: CKRecord) -> ChallengeDetails? {
        guard let startTime = record["startTime"] as? Date,
              let endTime = record["endTime"] as? Date,
              let goalSteps = record["goalSteps"] as? Int,
              let active = record["active"] as? Bool,
              let participants = record["participants"] as? [Participant],
              var recordId = record["recordId"] as? String
        else {
            return nil
        }
            
        
        return ChallengeDetails(startTime: startTime, endTime: endTime, goalSteps: Int32(goalSteps), active: active, participants: participants, recordId: recordId)
    }
    
}
