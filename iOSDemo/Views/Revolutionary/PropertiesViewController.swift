//
//  PropertiesViewController.swift
//  iOSDemo
//
//  Created by Guilherme Carlos Matuella on 17/02/19.
//  Copyright © 2019 gmatuella. All rights reserved.
//

import UIKit

private enum PropertiesPicker: Int, CaseIterable {
    
    enum DisplayStyle: String, CaseIterable {
        
        case none = "None"
        case percentage = "Current Percentage"
        case elapsedTime = "Elapsed Time"
        case remainingTime = "Remaining Time"
        case custom = "Custom"
        
        var associatedValue: Revolutionary.DisplayStyle {
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
    }
    
    enum ArcColor: String, CaseIterable {
        
        case coolPurple = "Cool Purple"
        case coolGreen = "Cool Green"
        case coolBlue = "Cool Blue"
        case coolPink = "Cool Pink"
        
        case black = "Black"
        case lightGray = "Light Gray"
        
        var associatedValue: UIColor {
            switch self {
            case .coolPurple: return .coolPurple
            case .coolGreen: return .coolGreen
            case .coolBlue: return .coolBlue
            case .coolPink: return .coolPink
            case .black: return .black
            case .lightGray: return .lightGray
            }
        }
    }
    
    enum ArcLineCap: String, CaseIterable {
        
        case round = "Round"
        case square = "Square"
        case butt = "Butt"
        
        var associatedValue: CGLineCap {
            switch self {
            case .round: return .round
            case .square: return .square
            case .butt: return .butt
            }
        }
    }
    
    case displayStyle = 0
    
    case mainArcColor = 1
    case backgroundArcColor = 2
    
    case mainArcLineCap = 3
    case backgroundArcLineCap = 4
    
    static func picker(withTag tag: Int) -> PropertiesPicker {
        guard let pickerWithTag = PropertiesPicker.allCases.first(where: { $0.rawValue == tag }) else {
            fatalError("No picker configured with tag: \(tag)")
        }
        return pickerWithTag
    }
    
    var associatedRows: Int {
        switch self {
        case .displayStyle: return DisplayStyle.allCases.count
        case .mainArcColor,
             .backgroundArcColor: return ArcColor.allCases.count
        case .mainArcLineCap,
             .backgroundArcLineCap: return ArcLineCap.allCases.count
        }
    }
    
    func description(at row: Int) -> String {
        switch self {
        case .displayStyle: return DisplayStyle.allCases[row].rawValue
        case .mainArcColor,
             .backgroundArcColor: return ArcColor.allCases[row].rawValue
        case .mainArcLineCap,
             .backgroundArcLineCap: return ArcLineCap.allCases[row].rawValue
        }
    }
}

protocol PropertiesDelegate: class {
    func properties(_ properties: PropertiesViewController, updatedStyle displayStyle: Revolutionary.DisplayStyle)
    func properties(_ properties: PropertiesViewController, updatedClockwise clockwise: Bool)
    func properties(_ properties: PropertiesViewController, updatedAnimationMultiplier animationMultiplier: Int)
    
    func properties(_ properties: PropertiesViewController, updatedBackgroundArc hasBackgroundArc: Bool)
    
    func properties(_ properties: PropertiesViewController, updatedMainArcColor mainArcColor: UIColor)
    func properties(_ properties: PropertiesViewController, updatedBackgroundArcColor backgroundArcColor: UIColor)
    
    func properties(_ properties: PropertiesViewController, updatedMainArcWidth mainArcWidth: CGFloat)
    func properties(_ properties: PropertiesViewController, updatedBackgroundArcWidth backgroundArcWidth: CGFloat)
    
    func properties(_ properties: PropertiesViewController, updatedMainArcLineCap mainArcLineCap: CGLineCap)
    func properties(_ properties: PropertiesViewController, updatedBackgroundArcLineCap backgroundArcLineCap: CGLineCap)
}

class PropertiesViewController: UIViewController {
 
    weak var delegate: PropertiesDelegate?
    
    private var clockwise: Bool! {
        didSet { delegate?.properties(self, updatedClockwise: clockwise) }
    }
    @IBOutlet private weak var clockwiseSwitch: UISwitch!
    
    private var displayStyle: Revolutionary.DisplayStyle! {
        didSet { delegate?.properties(self, updatedStyle: displayStyle) }
    }
    @IBOutlet private weak var displayStylePicker: UIPickerView!
    
    private var animationMultiplier: Int! {
        didSet {
            if let animationMultiplierText = animationMultiplierText {
                animationMultiplierText.text = "\(animationMultiplier!)"
                delegate?.properties(self, updatedAnimationMultiplier: animationMultiplier!)
            }
        }
    }
    @IBOutlet private weak var animationMultiplierText: UITextField!
    
    private var hasBackgroundArc: Bool! {
        didSet { delegate?.properties(self, updatedBackgroundArc: hasBackgroundArc) }
    }
    @IBOutlet private weak var backgroundArcSwitch: UISwitch!
    
    public var mainArcColor: UIColor! {
        didSet { delegate?.properties(self, updatedMainArcColor: mainArcColor) }
    }
    @IBOutlet private weak var mainArcColorPicker: UIPickerView!
    
    public var mainArcWidth: CGFloat! {
        didSet {
            if let mainArcWidthText = mainArcWidthText {
                mainArcWidthText.text = "\(mainArcWidth!)"
                delegate?.properties(self, updatedMainArcWidth: mainArcWidth)
            }
        }
    }
    @IBOutlet private weak var mainArcWidthText: UITextField!
    
    public var mainArcLineCap: CGLineCap! {
        didSet { delegate?.properties(self, updatedMainArcLineCap: mainArcLineCap) }
    }
    @IBOutlet private weak var mainArcLineCapPicker: UIPickerView!
    
    public var backgroundArcColor: UIColor! {
        didSet { delegate?.properties(self, updatedBackgroundArcColor: backgroundArcColor) }
    }
    @IBOutlet private weak var backgroundArcColorPicker: UIPickerView!
    
    public var backgroundArcWidth: CGFloat! {
        didSet {
            if let backgroundArcWidthText = backgroundArcWidthText {
                backgroundArcWidthText.text = "\(backgroundArcWidth!)"
                delegate?.properties(self, updatedMainArcWidth: backgroundArcWidth)
            }
        }
    }
    @IBOutlet private weak var backgroundArcWidthText: UITextField!
    
    public var backgroundArcLineCap: CGLineCap! {
        didSet { delegate?.properties(self, updatedBackgroundArcLineCap: backgroundArcLineCap) }
    }
    @IBOutlet private weak var backgroundArcLineCapPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addDismissKeyboard()
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        //Updating the UI with the initial values
        configurePickers()
        
        clockwiseSwitch.isOn = clockwise
        backgroundArcSwitch.isOn = hasBackgroundArc
        
        animationMultiplierText.text = "\(animationMultiplier!)"
        mainArcWidthText.text = "\(mainArcWidth!)"
        backgroundArcWidthText.text = "\(backgroundArcWidth!)"
    }
    
    private func configurePickers() {
        displayStylePicker.tag = PropertiesPicker.displayStyle.rawValue
        displayStylePicker.dataSource = self
        displayStylePicker.delegate = self
        //TODO:  //IMPROVE -> crashing
        let selectedDisplayIndex = PropertiesPicker.DisplayStyle.allCases.firstIndex { $0.associatedValue == displayStyle }!
        displayStylePicker.selectRow(selectedDisplayIndex, inComponent: 0, animated: false)
        
        mainArcColorPicker.tag = PropertiesPicker.mainArcColor.rawValue
        mainArcColorPicker.delegate = self
        mainArcColorPicker.dataSource = self
        //TODO:  //IMPROVE
        let selectedMainColorIndex = PropertiesPicker.ArcColor.allCases.firstIndex { $0.associatedValue == mainArcColor }!
        mainArcColorPicker.selectRow(selectedMainColorIndex, inComponent: 0, animated: false)
        
        backgroundArcColorPicker.tag = PropertiesPicker.backgroundArcColor.rawValue
        backgroundArcColorPicker.delegate = self
        backgroundArcColorPicker.dataSource = self
        let selectedBackgroundColorIndex = PropertiesPicker.ArcColor.allCases.firstIndex { $0.associatedValue == backgroundArcColor }!
        backgroundArcColorPicker.selectRow(selectedBackgroundColorIndex, inComponent: 0, animated: false)
        
        mainArcLineCapPicker.tag = PropertiesPicker.mainArcLineCap.rawValue
        mainArcLineCapPicker.delegate = self
        mainArcLineCapPicker.dataSource = self
        let selectedMainLineCapIndex = PropertiesPicker.ArcLineCap.allCases.firstIndex { $0.associatedValue == mainArcLineCap }!
        mainArcLineCapPicker.selectRow(selectedMainLineCapIndex, inComponent: 0, animated: false)
        
        backgroundArcLineCapPicker.tag = PropertiesPicker.backgroundArcLineCap.rawValue
        backgroundArcLineCapPicker.delegate = self
        backgroundArcLineCapPicker.dataSource = self
        let selectedBackgroundLineCapIndex = PropertiesPicker.ArcLineCap.allCases.firstIndex { $0.associatedValue == backgroundArcLineCap }!
        backgroundArcLineCapPicker.selectRow(selectedBackgroundLineCapIndex, inComponent: 0, animated: false)
    }
    
    @IBAction private func clockwiseTapped(_ sender: UISwitch) { clockwise = sender.isOn }
    
    @IBAction private func hasBackgroundArcTapped(_ sender: UISwitch) { hasBackgroundArc = sender.isOn }
    
    @IBAction private func animationMultiplierEndedEditing(_ sender: UITextField) {
        if let multiplierAsInt = Int(sender.text!), multiplierAsInt > 0 {
            animationMultiplier = multiplierAsInt
        } else {
            //Attribute again because the textField might be dirty with invalid characters
            sender.text = "\(animationMultiplier!)"
        }
    }
    
    @IBAction func mainArcWidthEndedEditing(_ sender: UITextField) {
        if let parsedMainArcWidth = Double(sender.text!), parsedMainArcWidth > 0 {
            mainArcWidth = CGFloat(parsedMainArcWidth)
        } else {
            //Attribute again because the textField might be dirty with invalid characters
            sender.text = "\(mainArcWidth!)"
        }
    }
    
    @IBAction func backgroundArcWidthEndedEditing(_ sender: UITextField) {
        if let parsedBackgroundArcWidth = Double(sender.text!), parsedBackgroundArcWidth > 0 {
            backgroundArcWidth = CGFloat(parsedBackgroundArcWidth)
        } else {
            //Attribute again because the textField might be dirty with invalid characters
            sender.text = "\(backgroundArcWidth!)"
        }
    }
    
    func configureUI(withRevolutionaryState revolutionary: Revolutionary) {
        clockwise = revolutionary.clockwise
        displayStyle = revolutionary.displayStyle
        animationMultiplier = revolutionary.animationMultiplier
        
        hasBackgroundArc = revolutionary.hasBackgroundArc
        
        mainArcColor = revolutionary.mainArcColor
        backgroundArcColor = revolutionary.backgroundArcColor
        mainArcWidth = revolutionary.mainArcWidth
        backgroundArcWidth = revolutionary.backgroundArcWidth
        mainArcLineCap = revolutionary.mainArcLineCap
        backgroundArcLineCap = revolutionary.backgroundArcLineCap
    }
}


extension PropertiesViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let selectedPicker = PropertiesPicker.picker(withTag: pickerView.tag)
        return selectedPicker.description(at: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedPicker = PropertiesPicker.picker(withTag: pickerView.tag)
        
        switch selectedPicker {
        case .displayStyle: displayStyle = PropertiesPicker.DisplayStyle.allCases[row].associatedValue
        case .mainArcColor: mainArcColor = PropertiesPicker.ArcColor.allCases[row].associatedValue
        case .backgroundArcColor: backgroundArcColor = PropertiesPicker.ArcColor.allCases[row].associatedValue
        case .mainArcLineCap: mainArcLineCap = PropertiesPicker.ArcLineCap.allCases[row].associatedValue
        case .backgroundArcLineCap: backgroundArcLineCap = PropertiesPicker.ArcLineCap.allCases[row].associatedValue
        }
    }
}

extension PropertiesViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let selectedPicker = PropertiesPicker.picker(withTag: pickerView.tag)
        return selectedPicker.associatedRows
    }
}
