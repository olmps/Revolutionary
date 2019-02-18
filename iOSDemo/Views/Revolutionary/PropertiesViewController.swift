//
//  PropertiesViewController.swift
//  iOSDemo
//
//  Created by Guilherme Carlos Matuella on 17/02/19.
//  Copyright © 2019 gmatuella. All rights reserved.
//

import UIKit

/**
 Mocked possible display styles, each with its own respective mocked data.
 */
enum MockedDisplayStyle: CaseIterable {
    case none
    case percentage
    case elapsedTime
    case remainingTime
    case custom
    
    var associatedMockedValue: Revolutionary.DisplayStyle {
        switch self {
        case .none: return .none
        case .percentage:
            let mockedDecimalPlaces = 2
            
            return .percentage(decimalPlaces: mockedDecimalPlaces)
        case .elapsedTime:
            let mockedDateFormatter = DateComponentsFormatter()
            mockedDateFormatter.allowedUnits = [.minute, .second]
            
            return .elapsedTime(formatter: mockedDateFormatter)
        case .remainingTime:
            let mockedDateFormatter = DateComponentsFormatter()
            mockedDateFormatter.allowedUnits = [.minute, .second]
            
            return .remainingTime(formatter: mockedDateFormatter)
        case .custom:
            let mockedCustomText = "Your Text"
            
            return .custom(text: mockedCustomText)
        }
    }
    
    var associatedDescription: String {
        switch self {
        case .none: return "None"
        case .percentage: return "Current Percentage"
        case .elapsedTime: return "Elapsed Time"
        case .remainingTime: return "Remaining Time"
        case .custom: return "Custom"
        }
    }
    
    static func index(of displayStyle: Revolutionary.DisplayStyle) -> Int {
        switch displayStyle {
        case .none: return 0
        case .percentage(_): return 1
        case .elapsedTime(_): return 2
        case .remainingTime(_): return 3
        case .custom(_): return 4
        }
    }
}

protocol PropertiesDelegate: class {
    func properties(_ properties: PropertiesViewController, updatedStyle displayStyle: Revolutionary.DisplayStyle)
    func properties(_ properties: PropertiesViewController, updatedClockwise clockwise: Bool)
    func properties(_ properties: PropertiesViewController, updatedAnimationMultiplier animationMultiplier: Int)
}

class PropertiesViewController: UIViewController {
 
    weak var delegate: PropertiesDelegate?
    
    private var animationMultiplier: Int! {
        didSet {
            if let animationMultiplierText = animationMultiplierText {
                animationMultiplierText.text = "\(animationMultiplier!)"
                delegate?.properties(self, updatedAnimationMultiplier: animationMultiplier!)
            }
        }
    }
    
    @IBOutlet private weak var animationMultiplierText: UITextField!
    
    private var clockwise: Bool! {
        didSet { delegate?.properties(self, updatedClockwise: clockwise) }
    }
    @IBOutlet private weak var clockwiseSwitch: UISwitch!
    
    private var displayStyle: Revolutionary.DisplayStyle! {
        didSet { delegate?.properties(self, updatedStyle: displayStyle) }
    }
    @IBOutlet private weak var displayStylePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        displayStylePicker.dataSource = self
        displayStylePicker.delegate = self
        
        //Updating the UI with the initial values
        clockwiseSwitch.isOn = clockwise
        
        let selectedDisplayIndex = MockedDisplayStyle.index(of: displayStyle)
        displayStylePicker.selectRow(selectedDisplayIndex, inComponent: 0, animated: false)
        
        animationMultiplierText.text = "\(animationMultiplier!)"
    }
    
    @IBAction func clockwiseTapped(_ sender: UISwitch) { clockwise = sender.isOn }
    
    @IBAction func animationMultiplierEndedEditing(_ sender: UITextField) {
        if let multiplierAsInt = Int(sender.text!), multiplierAsInt > 0 {
            animationMultiplier = multiplierAsInt
        } else {
            //Attribute again because the textField might be dirty with invalid characters
            animationMultiplierText.text = "\(animationMultiplier!)"
        }
    }
    
    func configureUI(withRevolutionaryState revolutionary: Revolutionary) {
        clockwise = revolutionary.clockwise
        displayStyle = revolutionary.displayStyle
        animationMultiplier = revolutionary.animationMultiplier
    }
}


extension PropertiesViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MockedDisplayStyle.allCases[row].associatedDescription
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        displayStyle = MockedDisplayStyle.allCases[row].associatedMockedValue
    }
}

extension PropertiesViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MockedDisplayStyle.allCases.count
    }
}
