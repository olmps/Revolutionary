//
//  RevolutionaryBuilder.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 12/02/19.
//  Copyright © 2019 gmatuella. All rights reserved.
//

import SpriteKit

/// Helper to instantiate the properties of a `Revolutionary` with less verbosity.
public class RevolutionaryBuilder {
    
    /// Initial position of the main arc. Defaults to `false`.
    public var startsCompleted: Bool = false
    
    // MARK: - Shared Properties (Between Revolutionary and RevolutionaryBuilder)
    
    /// Defaults to `white`.
    public var mainArcColor: UIColor?
    
    /// Defaults to `5`.
    public var mainArcWidth: CGFloat?
    
    /// Defaults to `round`.
    public var mainArcLineCap: CGLineCap?
    
    /// Manages the appearance of the background arc. Defaults to `true`.
    public var hasBackgroundArc: Bool?
    
    /// Defaults to `lightGray`.
    public var backgroundArcColor: UIColor?
    
    /// Defaults to `5`.
    public var backgroundArcWidth: CGFloat?
    
    /// Defaults to `round`.
    public var backgroundArcLineCap: CGLineCap?
    
    /// Display style of the `displayLabel`. Defaults to `none`.
    public var displayStyle: Revolutionary.DisplayStyle?
    
    /// Shows the state of the `Revolutionary` given the current `displayStyle` format.
    public var displayLabel: SKLabelNode?
    
    /// Orientation of the progress arc. Defaults to `true`.
    public var clockwise: Bool?
    
    /**
     The "animation visual accuracy multiplier".
     
     The `animationMultiplier` will affect directly the number of animations (or `SKAction`) generated in an arbitrary `TimeInterval`.
     
     The greater this number, less "stutter" will be apparent in the animation. The contrary is likewise.
     
     Defaults to `1000`, which is a reasonable amount of `SKAction` given the fact that in most cases it does not loses the aspect of "continous" animation
     and the keeping the performance at a decent level.
     */
    public var animationMultiplier: Int?
    
    public init(_ revolutionaryBuilder: (RevolutionaryBuilder) -> ()) {
        revolutionaryBuilder(self)
    }
}
