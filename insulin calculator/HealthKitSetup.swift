//
//  HealthKit Setup.swift
//  insulin calculator
//
//  Created by Frank Foster on 2/25/20.
//  Copyright © 2020 Frank Foster. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
  
  private enum HealthkitSetupError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
  }
  
  class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
    guard HKHealthStore.isHealthDataAvailable() else {
      completion(false, HealthkitSetupError.notAvailableOnDevice)
      return
    }
    
   guard let carbsRecorded = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates),
         let bloodSugarRecorded = HKObjectType.quantityType(forIdentifier: .bloodGlucose),
         let insulinRecorded = HKObjectType.quantityType(forIdentifier: .insulinDelivery) else {
        completion(false, HealthkitSetupError.dataTypeNotAvailable)
        return
    }
    
    let healthKitToWrite: Set<HKSampleType> = [carbsRecorded, bloodSugarRecorded, insulinRecorded]
    let healthKitToRead: Set<HKSampleType> = [carbsRecorded, bloodSugarRecorded, insulinRecorded]
    
    HKHealthStore().requestAuthorization(toShare: healthKitToWrite,
                                         read: healthKitToRead) { (success, error) in
      completion(success, error)
    }
  }
}
