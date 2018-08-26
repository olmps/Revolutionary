//
//  UIColor.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var random: UIColor {
        return UIColor(red: CGFloat.random,
                       green: CGFloat.random,
                       blue: CGFloat.random,
                       alpha: 1)
    }
}
