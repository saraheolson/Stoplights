//
//  CurrentWorkoutViewController.swift
//  Stoplights
//
//  Created by SarahEOlson on 9/9/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import UIKit
import HealthKit

class CurrentWorkoutViewController: UIViewController {

    @IBOutlet var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        heartRateLabel.text = "Gathering..."
        
        HealthManager.sharedInstance.authorizeHealthKit { (success, error) in
            print(success)
        }

        HealthManager.sharedInstance.heartRateDelegate = self
        HealthManager.sharedInstance.workoutDelegate = self
        
//        #if (TARGET_OS_SIMULATOR)
            HealthManager.sharedInstance.createMockData()
//        #endif

        HealthManager.sharedInstance.retrieveHeartRate()
    }
}
extension CurrentWorkoutViewController: HeartRateDelegate {
    
    func didReceiveNewHeartRate(heartRate: HKQuantitySample) {
        
        DispatchQueue.main.async {
            let theValue = heartRate.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.heartRateLabel.text = "\(Int(theValue))"
        }
    }
}

extension CurrentWorkoutViewController: WorkoutDelegate {
    
    func didReceiveNewWorkout(workout: HKWorkout) {
        let workoutEvents = workout.workoutEvents
        
    }
}
