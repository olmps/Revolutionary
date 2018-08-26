//
//  CGFloat.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import UIKit

extension CGFloat {
    
    /// Rounds the CGFloat to decimal places value
    func rounded(toPlaces places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        
        return (self * divisor).rounded() / divisor
    }
}
