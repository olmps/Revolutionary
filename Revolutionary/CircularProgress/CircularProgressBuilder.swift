//
//  CircularProgressBuilder.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 30/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

public class CircularProgressBuilder {
    
    public var circleColor: UIColor?
    public var circleLineWidth: CGFloat?
    public var circleRadius: CGFloat?
    public var lineCap: CGLineCap?
    
    public var background: SKShapeNode?
    
    public var displayLabel: SKLabelNode?
    public var shouldUpdateDisplay: Bool?
    
    public var clockwise: Bool?
    
    public init(_ circleProgressBuilder: (CircularProgressBuilder) -> ()) {
        circleProgressBuilder(self)
    }
}
