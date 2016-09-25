//
//  ViewController.swift
//  Stoplights
//
//  Created by Floater on 9/9/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    @IBOutlet var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        heartRateLabel.text = "Gathering..."
        
        HealthManager.sharedInstance.authorizeHealthKit { (success, error) in
            print(success)
        }

        HealthManager.sharedInstance.heartRateDelegate = self
        
//        #if (TARGET_OS_SIMULATOR)
            HealthManager.sharedInstance.createMockData()
//        #endif

        HealthManager.sharedInstance.retrieveHeartRate()
    }
}
extension ViewController: HeartRateDelegate {
    
    func didReceiveNewHeartRate(heartRate: HKQuantitySample) {
        
        DispatchQueue.main.async {
            let theValue = heartRate.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.heartRateLabel.text = "\(Int(theValue))"
        }
    }
}
