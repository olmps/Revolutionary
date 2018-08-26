//
//  CGFloat.swift
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
