//
//  Extensions.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import UIKit

extension CGFloat {
    
    /// Random CGFloat between 0 and 1.
    static var random: CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
}

extension UIViewController {
    
    func addDismissTap() {
        let dismissTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(dismissTap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    static var lightBlue: UIColor {
        return UIColor(red: 145 / 255, green: 179 / 255, blue: 188 / 255, alpha: 1)
    }
    
    static var darkBlue: UIColor {
        return UIColor(red: 91 / 255, green: 125 / 255, blue: 135 / 255, alpha: 1)
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        setBackgroundImage(colorImage, for: forState)
    }
}

extension UISwitch {
    static func `default`() -> UISwitch {
        let defaultSwitch = UISwitch()
        defaultSwitch.translatesAutoresizingMaskIntoConstraints = false
        defaultSwitch.onTintColor = .lightBlue
        
        return defaultSwitch
    }
}

extension UIStepper {
    static func `default`(stepVal: Double = 1, minVal: Double, maxVal: Double) -> UIStepper {
        let defaultStepper = UIStepper()
        defaultStepper.translatesAutoresizingMaskIntoConstraints = false
        
        defaultStepper.minimumValue = minVal
        defaultStepper.stepValue = stepVal
        defaultStepper.maximumValue = maxVal
        
        defaultStepper.tintColor = .lightBlue
        
        return defaultStepper
    }
}

extension UILabel {
    static func `default`(fontSize: CGFloat, text: String? = nil) -> UILabel {
        let defaultLabel = UILabel()
        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
        defaultLabel.font = .systemFont(ofSize: fontSize, weight: .semibold)
        defaultLabel.textColor = .darkBlue
        defaultLabel.text = text
        
        return defaultLabel
    }
}
