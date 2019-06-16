//
//  UIExtensions.swift
//  iOSDemo
//
//  Created by Guilherme Carlos Matuella on 18/02/19.
//  Copyright © 2019 gmatuella. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var coolPurple: UIColor {
        return UIColor(red: 121 / 255, green: 92 / 255, blue: 212 / 255, alpha: 1)
    }
    
    static var coolGreen: UIColor {
        return UIColor(red: 92 / 255, green: 212 / 255, blue: 121 / 255, alpha: 1)
    }
    
    static var coolPink: UIColor {
        return UIColor(red: 212 / 255, green: 92 / 255, blue: 183 / 255, alpha: 1)
    }
    
    static var coolBlue: UIColor {
        return UIColor(red: 92 / 255, green: 183 / 255, blue: 212 / 255, alpha: 1)
    }
}

extension UIView {
    
    convenience init(translatingAutoresizingMaskIntoConstraints translatesAutoresizingMaskIntoConstraints: Bool) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
    }
    
    func addSubviews(_ views: [UIView]) { views.forEach { addSubview($0) } }
    
    func addDismissKeyboard() {
        let dismissSelector = #selector(dismissKeyboard)
        let dismissTap = UITapGestureRecognizer(target: self, action: dismissSelector)
        addGestureRecognizer(dismissTap)
    }
    
    @objc private func dismissKeyboard() { endEditing(true) }
}

extension UILabel {
    
    static func instanceWithDefaultProperties(withText text: String? = nil) -> UILabel {
        let defaultLabel = UILabel()
        defaultLabel.text = text
        defaultLabel.textAlignment = .left
        defaultLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        defaultLabel.textColor = .coolPurple
        
        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
        return defaultLabel
    }
}

extension UIStepper {
    
    static func instanceWithDefaultProperties() -> UIStepper {
        let defaultStepper = UIStepper()
        defaultStepper.tintColor = .coolPurple
        defaultStepper.stepValue = 1
        defaultStepper.minimumValue = 1
        defaultStepper.value = 3
        
        defaultStepper.translatesAutoresizingMaskIntoConstraints = false
        return defaultStepper
    }
}

extension UITextField {
    
    static func instanceWithDefaultProperties() -> UITextField {
        
        let progressTextField = UITextField()
        progressTextField.keyboardType = .decimalPad
        progressTextField.textAlignment = .center
        progressTextField.borderStyle = .roundedRect
        progressTextField.textColor = .coolPurple
        progressTextField.font = .systemFont(ofSize: 15, weight: .regular)
        
        progressTextField.translatesAutoresizingMaskIntoConstraints = false
        return progressTextField
    }
}
