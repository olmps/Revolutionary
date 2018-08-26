//
//  CircularTimerScene.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularTimerScene: SKScene {
    
    private var timerNode: CircularTimer!
    
    override func didMove(to view: SKView) {
        let smallestSide = size.height > size.width ? size.height : size.width
        timerNode = CircularTimer(withRadius: smallestSide / 3, width: smallestSide / 30, color: .random)
        timerNode.position = CGPoint(x: frame.midX, y: frame.midY)

        addChild(timerNode)
    }
    
    func animate(withDuration duration: Int, revolutions: Int, clockwise: Bool) {
        timerNode.circleColor = .random
        timerNode.play(withRevolutionTime: Double(duration),
                       amountOfRevolutions: revolutions,
                       clockwise: clockwise)
    }
}
