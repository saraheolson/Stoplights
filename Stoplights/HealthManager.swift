//
//  HealthManager.swift
//  Stoplights
//
//  Created by Floater on 9/24/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func didReceiveNewHeartRate(heartRate: HKQuantitySample)
}

/**
 *  Interface for retrieving and saving health data.
 */
class HealthManager {

    class var sharedInstance: HealthManager {
        struct Singleton {
            static let instance = HealthManager()
        }
        return Singleton.instance
    }
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()

    let workoutType = HKObjectType.workoutType()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
    
    var isAuthorized = false
    var heartRateDelegate: HeartRateDelegate?
    
    func authorizeHealthKit(completion: ((_ wasSuccessful: Bool, _ wasError: NSError?) -> Void)!) {
        
        let healthKitTypesToRead: Set<HKObjectType>
        let healthKitTypesToWrite: Set<HKSampleType>
        
        if let heartRateType = heartRateType {
            healthKitTypesToRead = [workoutType, heartRateType]
            healthKitTypesToWrite = [workoutType, heartRateType]
        } else {
            healthKitTypesToRead = [workoutType]
            healthKitTypesToWrite = [workoutType]
        }
        
        healthStore?.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead, completion: { (success, error) in
            
            if success {
                print("SUCCESS")
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    func createMockData() {
        
        // Generate a random number between 80 and 100
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min") , doubleValue: Double(arc4random_uniform(80) + 100))
        
        // Create the sample
        if let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            let heartSample = HKQuantitySample(type: heartRateQuantityType, quantity: heartRateQuantity, start: Date(), end: Date())
            
            // save the sample
            healthStore?.save(heartSample, withCompletion: { (success, error) in
                if let error = error {
                    print("Error saving heart rate sample: \(error.localizedDescription)")
                }
            })
        }
    }
    
    func retrieveHeartRate() {
        
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            
            let heartRateQuery = HKSampleQuery(sampleType: heartRate, predicate: nil, limit: 1, sortDescriptors: nil) { [weak self] (query, results, error) in
                
                if let results = results as? [HKQuantitySample] {
                    print("Results: \(results)")
                    self?.heartRateDelegate?.didReceiveNewHeartRate(heartRate: results[0])
                } else {
                    print("ERROR")
                }
            }
            healthStore?.execute(heartRateQuery)
        }
    }
}
