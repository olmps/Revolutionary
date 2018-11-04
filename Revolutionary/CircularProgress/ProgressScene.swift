//
//  ProgressScene.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

open class ProgressScene: SKScene {
    
    private var _progress: CircularProgress!
    public var progress: CircularProgress {
        if _progress == nil {
            fatalError("`CircularProgress` not configured. Please call `configure(_:)` or initialize using `init(size:builder:)")
        }
        
        return _progress
    }
    
    // MARK: Initializers and Configuration
    
    public init(size: CGSize, builder: CircularProgressBuilder?) {
        _progress = CircularProgress(withBuilder: builder)
        super.init(size: size)
        
        commonInit()
    }
    
    public override init(size: CGSize) {
        super.init(size: size)
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(_ circularProgressBuilder: CircularProgressBuilder?) {
        _progress = CircularProgress(withBuilder: circularProgressBuilder)
    
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        progress.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(_progress)
    }
}
