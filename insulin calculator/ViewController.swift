//
//  ViewController.swift
//  insulin calculator
//
//  Created by Frank Foster on 2/25/20.
//  Copyright © 2020 Frank Foster. All rights reserved.
//

import HealthKit
import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var targetBloodSugar: UITextField!
    @IBOutlet weak var ratioBloodSugar: UITextField!
    @IBOutlet weak var ratioCarbs: UITextField!
    @IBOutlet weak var currentBloodSugar: UITextField!
    @IBOutlet weak var currentCarbs: UITextField!
    @IBOutlet weak var labelResults: UILabel!
    
    
    var insulinValueMGDL = "Mg/dL"
    var currentDate = Date()
    
    var carbsInput: Double? {
        guard let carbsTextValue = currentCarbs.text else {
            return nil
        }
        return Double(carbsTextValue)
    }
    
    var bglInput: Double? {
         guard let bglTextValue = currentBloodSugar.text else {
             return nil
         }
         return Double(bglTextValue)
     }
    
    var targetInput: Double? {
        guard let targetBGLTextValue = targetBloodSugar.text else {
            return nil
        }
        return Double(targetBGLTextValue)
    }
    
    var ratioBGLInput: Double? {
        guard  let ratioBGLTextValue = ratioBloodSugar.text else {
            return nil
        }
        return Double (ratioBGLTextValue)
    }
    
    var ratioCarbsInput: Double? {
        guard let ratioCarbsTextValue = ratioCarbs.text else {
            return nil
        }
        return Double (ratioCarbsTextValue)
    }
    
    private func authorizeHealthKit () {
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
              
          guard authorized else {
                
            let baseMessage = "HealthKit Authorization Failed"
                
            if let error = error {
              print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
              print(baseMessage)
            }
                
            return
          }
              
          print("HealthKit Successfully Authorized.")
        }
    }
    
    
    private func saveHealthData (date: Date) {
        guard let carbHealthKitType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates),
            let bglHealthKitType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
//            let insulinHealthKitType = HKQuantityType.quantityType(forIdentifier: .insulinDelivery)
            else {
            fatalError("no data found")
        }
        
        
        
        let carbsHealthKitQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: carbsInput!)
        let carbsHealthKitSample = HKQuantitySample(type: carbHealthKitType, quantity: carbsHealthKitQuantity, start: date, end: date)
        
        
        let bglHealthKitQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: HKMetricPrefix.deci)), doubleValue: bglInput!)
        let bglHealthKitSample = HKQuantitySample(type: bglHealthKitType, quantity: bglHealthKitQuantity, start:  date, end: date)
        
//         MARK: Work on this part, need to rework calculation to have the result of insulin separate
//        let insulinHealthKitQuantity = HKQuantity(unit: HKUnit.internationalUnit(), doubleValue: labelResults.text)
        
        let arrayOfHealthKitData = [carbsHealthKitSample, bglHealthKitSample]
        
        HKHealthStore().save(arrayOfHealthKitData) { (success, error) in
            if let error = error {
              print("Error Saving carbs: \(error.localizedDescription)")
            } else {
              print("Successfully saved BMI Sample")
            }
            
        }
            
        
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit()
        
    }

    func calculateInsulin () {
        
        if targetBloodSugar != nil && ratioBloodSugar != nil && ratioCarbs != nil && currentBloodSugar != nil && currentCarbs != nil {
            
            let bglCalc = Double (((bglInput)! - (targetInput)!) / (ratioBGLInput)!)
            let carbCalc = Double ((carbsInput)! / (ratioCarbsInput)!)
            
            let insulinAmount = ((bglCalc) + (carbCalc))
            
            labelResults.adjustsFontSizeToFitWidth = true
            labelResults.text = "You should take \(insulinAmount) \(insulinValueMGDL)"
            
            
            print ("looks good")
            return
        } else {
            print ("no bueno")
        }
        
    }
    
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        calculateInsulin()
        saveHealthData(date: currentDate)
    }
    
}

