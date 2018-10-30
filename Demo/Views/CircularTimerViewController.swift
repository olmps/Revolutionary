//
//  CircularTimerViewController.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularTimerViewController: UIViewController {
    
    private enum State {
        case animating
        case paused
        case stopped
    }
    private var state = State.stopped
    
    private var duration: Int = 0 { didSet { updateDurationLabel() } }
    @IBOutlet private weak var durationLabel: UILabel!
    
    private var revolutions: Int = 0 { didSet { updateRevolutionsLabel() } }
    @IBOutlet private weak var revolutionsLabel: UILabel!
    
    private var reversed: Bool = false
    private var clockwise: Bool = true
    
    private var skview: SKView!
    private var timerScene: TimerScene!
    @IBOutlet private weak var skViewWrapper: UIView!
    @IBOutlet private weak var animateButton: UIButton!
    
    //Need to call on viewDidAppear because the `skviewWrapper`
    //does not contains its correct contentSize yet.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if skview == nil {
            duration = 6
            revolutions = 3
            
            let frame = skViewWrapper.frame
            skview = SKView(frame: frame)
            skViewWrapper.addSubview(skview)
            
            timerScene = TimerScene(size: skview.bounds.size,
                                    circularProgressBuilder: CircularProgressBuilder {
                let smallestSide = frame.height > frame.width ? frame.width : frame.height
                $0.circleRadius = smallestSide / 3
                $0.circleLineWidth = 10
            })
            timerScene.timer.delegate = self
            
            skview.presentScene(timerScene)
            skview.showsDrawCount = true
            skview.showsNodeCount = true
        }
    }
    
    @IBAction private func durationStepperTapped(_ sender: UIStepper) {
        duration = Int(sender.value)
    }
    
    @IBAction private func revolutionsStepperTapped(_ sender: UIStepper) {
        revolutions = Int(sender.value)
    }
    
    @IBAction private func reversedSwitchTapped(_ sender: UISwitch) {
        reversed = sender.isOn
    }
    
    @IBAction func clockwiseSwitchTapped(_ sender: UISwitch) {
        clockwise = sender.isOn
    }
    
    @IBAction private func animateTapped(_ sender: UIButton) {
        timerScene.timer.circleColor = .random
        
        switch state {
        case .animating:
            state = .paused
            animateButton.setTitle("Continue", for: .normal)
            timerScene.isPaused = true
            
        case .paused:
            state = .animating
            animateButton.setTitle("Pause", for: .normal)
            timerScene.isPaused = false
            
        case .stopped:
            state = .animating
            animateButton.setTitle("Pause", for: .normal)
            
            timerScene.timer.clockwise = clockwise
            timerScene.timer.play(withRevolutionTime: TimeInterval(duration),
                                  amountOfRevolutions: revolutions,
                                  reversed: reversed)
        }
    }
    
    private func updateDurationLabel() {
        durationLabel.text = "Rev. Duration: \(duration) sec."
    }
    
    private func updateRevolutionsLabel() {
        revolutionsLabel.text = "Revolutions: \(revolutions)x"
    }
}

extension CircularTimerViewController: CircularTimerDelegate {
    func timer(_ circularTimer: CircularTimer, finishedWithElapsedTime elapsedTime: TimeInterval) {
        animateButton.setTitle("ANIMATE!", for: .normal)
        state = .stopped
    }
}
