//
//  CircularProgressScene.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularProgressScene: SKScene {
    
    private var progressNode: CircularProgress!
    
    override func didMove(to view: SKView) {
        let smallestSide = size.height > size.width ? size.height : size.width
        progressNode = CircularProgress(withRadius: smallestSide / 3, width: smallestSide / 30, color: .random)
        progressNode.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(progressNode)
    }
    
    func animateProgress(withDuration duration: Int, progress: CGFloat) {
        progressNode.circleColor = .random
        
        progressNode.updateProgress(progress,
                                    duration: TimeInterval(duration))
    }
}
