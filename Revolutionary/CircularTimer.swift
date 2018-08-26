//
//  CircularTimer.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

//TODO: Create class description
public class CircularTimer: CircularProgress {
    
    //TODO: Create description
    public private(set) var shouldRepeatForever: Bool = false
    public private(set) var isClockwise: Bool = true
    public private(set) var currentRevolution: Int = 0
    public private(set) var totalRevolutions: Int = 0
    
    //TODO: Create description
    public func play(withRevolutionTime revolutionTime: TimeInterval,
                     amountOfRevolutions: Int,
                     clockwise: Bool = true) {
        currentRevolution = 0
        totalRevolutions = amountOfRevolutions
        isClockwise = clockwise
        
        playRevolution(withDuration: revolutionTime)
    }
    
    //TODO: Create description
    public func playForever(withRevolutionTime revolutionTime: TimeInterval,
                            clockwise: Bool = true) {
        playRevolution(withDuration: revolutionTime)
    }
    
    public func stopTimer() {
        shouldRepeatForever = false
        reset()
    }
    
    // MARK: Auxiliar Functions
    
    /**
     Recursively calls the `updateProgress(_: duration: completion:)` of `CircularProgress` and manages its completion to play the next revolution.
     
     The recursion is stopped when `currentRevolution` is equals to `totalRevolutions`.
     
     `isClockwise` determines if the animation will start "completed" or not.
     
     If `shouldRepeatForever == true`, the recursion will only be stopped when `stopTimer()` is called.
     - Parameters:
        - duration: the amount of time spent in each revolution.
     */
    private func playRevolution(withDuration duration: TimeInterval) {
        reset(completed: !isClockwise)
        
        guard shouldRepeatForever || currentRevolution != totalRevolutions else { return }
        currentRevolution += 1
        
        let targetProgress: CGFloat = isClockwise ? 1 : 0
        
        updateProgress(targetProgress, duration: duration) {
            self.playRevolution(withDuration: duration)
        }
    }
}
