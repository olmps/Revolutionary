//
//  TimerScene.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 30/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

open class TimerScene: SKScene {
    
    private var _timer: CircularTimer!
    public var timer: CircularTimer {
        if _timer == nil {
            fatalError("`CircularTimer` not configured. Please call `configure(_:)` or initialize using `init(size:builder:)")
        }

        return _timer
    }
    
    // MARK: Initializers and Configuration
    
    public init(size: CGSize, builder: CircularProgressBuilder?) {
        _timer = CircularTimer(withBuilder: builder)
        super.init(size: size)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(_ circularProgressBuilder: CircularProgressBuilder?) {
        _timer = CircularTimer(withBuilder: circularProgressBuilder)
    }
    
    private func commonInit() {
        backgroundColor = .clear
        timer.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(_timer)
    }
}
