//
//  CircularTimerViewController.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularTimerViewController: RevolutionaryDemoViewController {
    
    // MARK: Timer Scene UI
    
    private let timerScene = TimerScene()
    private func setupTimer() {
        let skViewSize = skView.bounds.size
        timerScene.size = skViewSize
        
        timerScene.configure(CircularProgressBuilder {
            let smallestAxis = skViewSize.height > skViewSize.width ? skViewSize.width : skViewSize.height
            $0.circleRadius = (smallestAxis / 2) - UI.outsidePadding
            
            $0.circleLineWidth = 10
            $0.circleColor = .darkBlue
        })

        skView.presentScene(timerScene)
    }
    
    // MARK: Duration UI
    
    private var revolutionDuration: Double = 2
    private let durationLabel = UILabel.default(fontSize: 21)
    private let durationStepper = UIStepper.default(minVal: 1, maxVal: 1000)
    private func setupDurationContent() {
        durationStepper.value = revolutionDuration
        durationLabel.text = "Rev. Duration: \(Int(revolutionDuration))"
        
        durationStepper.addTarget(self, action: #selector(CircularTimerViewController.durationTapped(_:)), for: .primaryActionTriggered)
        addPairToContentStack(firstView: durationLabel, secondView: durationStepper)
    }
    
    @objc private func durationTapped(_ stepper: UIStepper) {
        revolutionDuration = stepper.value
        durationLabel.text = "Rev. Duration: \(Int(stepper.value))"
    }
    
    // MARK: Amount UI
    
    private var revolutionsAmount: Double = 2
    private let amountLabel = UILabel.default(fontSize: 21)
    private let amountStepper = UIStepper.default(minVal: 1, maxVal: 1000)
    private func setupAmountContent() {
        amountStepper.value = revolutionsAmount
        amountLabel.text = "Rev. Amount: \(Int(revolutionsAmount))"
        
        amountStepper.addTarget(self, action: #selector(CircularTimerViewController.amountTapped(_:)), for: .primaryActionTriggered)
        addPairToContentStack(firstView: amountLabel, secondView: amountStepper)
    }
    
    @objc private func amountTapped(_ stepper: UIStepper) {
        revolutionsAmount = stepper.value
        amountLabel.text = "Rev. Duration: \(Int(stepper.value))"
    }
    
    // MARK: Endless UI
    
    private var endlessLoop = false
    private let endlessLoopLabel = UILabel.default(fontSize: 21)
    private let endlessLoopSwitch = UISwitch.default()
    private func setupEndlessLoopContent() {
        endlessLoopLabel.text = "Endless Loop"
        endlessLoopSwitch.addTarget(self, action: #selector(CircularTimerViewController.endlessLoopTapped), for: .primaryActionTriggered)
        addPairToContentStack(firstView: endlessLoopLabel, secondView: endlessLoopSwitch)
    }
    
    @objc private func endlessLoopTapped() {
        endlessLoop = endlessLoopSwitch.isOn
        durationStepper.isEnabled = !endlessLoopSwitch.isOn
        amountStepper.isEnabled = !endlessLoopSwitch.isOn
    }
    
    // MARK: Clockwise UI
    
    private var clockwise = true
    private let clockwiseLabel = UILabel.default(fontSize: 21)
    private let clockwiseSwitch = UISwitch.default()
    private func setupClockwiseContent() {
        clockwiseLabel.text = "Clockwise"
        clockwiseSwitch.addTarget(self, action: #selector(CircularTimerViewController.clockwiseTapped), for: .primaryActionTriggered)
        addPairToContentStack(firstView: clockwiseLabel, secondView: clockwiseSwitch)
    }
    
    @objc private func clockwiseTapped() {
        clockwise = clockwiseSwitch.isOn
    }
    
    // MARK: Reversed UI
    
    private var reversed = false
    private let reversedLabel = UILabel.default(fontSize: 21)
    private let reversedSwitch = UISwitch.default()
    private func setupReversedContent() {
        reversedLabel.text = "Reversed"
        reversedSwitch.addTarget(self, action: #selector(CircularTimerViewController.reversedTapped), for: .primaryActionTriggered)
        addPairToContentStack(firstView: reversedLabel, secondView: reversedSwitch)
    }
    
    @objc private func reversedTapped() {
        reversed = reversedSwitch.isOn
    }
    
    //
    
    @objc private func animateTapped(_ sender: UIButton) {
//        switch state {
//        case .animating:
//            state = .paused
//            sender.setTitle("Continue", for: .normal)
//            progressScene.isPaused = true
//
//        case .paused:
//            state = .animating
//            sender.setTitle("Pause", for: .normal)
//            progressScene.isPaused = false
//
//        case .stopped:
//            state = .animating
//            sender.setTitle("Pause", for: .normal)
//
//            progressScene.progress.clockwise = clockwise
//            progressScene.progress.updateProgress(progress, duration: TimeInterval(duration)) {
//                sender.setTitle("Animate", for: .normal)
//                self.state = .stopped
//            }
//        }
    }
    

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateButton.addTarget(self, action: #selector(CircularTimerViewController.animateTapped(_:)), for: .primaryActionTriggered)
        
        setupTimer()
        
        setupDurationContent()
        setupAmountContent()
        setupEndlessLoopContent()
        setupClockwiseContent()
        setupReversedContent()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let currentScrollViewSize = scrollViewWrapper.contentSize
//        scrollViewWrapper.contentSize = CGSize(width: currentScrollViewSize.width, height: currentScrollViewSize.height + 88)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        scrollViewWrapper.contentSi
    }
}
