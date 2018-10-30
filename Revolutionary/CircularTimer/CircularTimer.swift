//
//  CircularTimer.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

public protocol CircularTimerDelegate: class {
    func timer(_ circularTimer: CircularTimer, finishedWithElapsedTime elapsedTime: TimeInterval)
}

//TODO: Create class description
open class CircularTimer: CircularProgress {
    
    open weak var delegate: CircularTimerDelegate?
    
    //TODO: Create description
    public private(set) var shouldRepeatForever: Bool = false
    public private(set) var reversed: Bool = false
    public private(set) var currentRevolution: Int = 0
    public private(set) var totalRevolutions: Int = 0
    
    public var timerElapsedTime: TimeInterval {
        let concludedRevolutions = TimeInterval(currentRevolution - 1)
        
        if (concludedRevolutions) > 0 {
            return concludedRevolutions * targetDuration + elapsedTime
        } else {
            return elapsedTime
        }
    }
    
    private var formattedElapsedTime: String {
        let elapsedTime = Int(timerElapsedTime) + 1
        
        let minutes = (elapsedTime / 60) % 60
        let seconds = elapsedTime % 60
        
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    public var isDisplayEnabled: Bool = true
    
    public func configure(showingElapsedTime displayEnabled: Bool) {
        isDisplayEnabled = displayEnabled
        
        guard isDisplayEnabled && displayStyle == .none else {
            fatalError("""
                        Can't assign Timer display to true while displayStyle is different than .none!
                        Please change the displayStyle to .none or do not enable Timer display.
                        """)
        }
        
        if isDisplayEnabled { updateDisplay(formattedElapsedTime) }
    }
    
    //TODO: Create description
    public func play(withRevolutionTime revolutionTime: TimeInterval,
                     amountOfRevolutions: Int,
                     reversed: Bool = false) {
        self.reversed = reversed
        currentRevolution = 0
        totalRevolutions = amountOfRevolutions
        
        playRevolution(withDuration: revolutionTime)
    }
    
    //TODO: Create description
    public func playForever(withRevolutionTime revolutionTime: TimeInterval,
                            reversed: Bool = false) {
        self.reversed = reversed
        shouldRepeatForever = true
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
        reset(completed: reversed)
        
        guard shouldRepeatForever || currentRevolution != totalRevolutions else {
            delegate?.timer(self, finishedWithElapsedTime: timerElapsedTime)
            return
        }
        
        currentRevolution += 1
        
        let targetProgress: CGFloat = reversed ? 0 : 1
        
        updateProgress(targetProgress, duration: duration) {
            if self.isDisplayEnabled { self.updateDisplay(self.formattedElapsedTime) }
            self.playRevolution(withDuration: duration)
        }
    }
}
