//
//  CircularProgressViewController.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 22/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularProgressViewController: RevolutionaryDemoViewController {
    
    // MARK: SKView Contents
    
    private let progressScene = ProgressScene()
    private func setupProgress() {
        let skViewSize = skView.bounds.size
        progressScene.size = skViewSize
        
        progressScene.configure(CircularProgressBuilder {
            let smallestSide = skViewSize.height > skViewSize.width ? skViewSize.width : skViewSize.height
            $0.circleRadius = (smallestSide / 2) - UI.outsidePadding
            
            $0.circleLineWidth = 10
            $0.circleColor = .darkBlue
        })
        
        skView.presentScene(progressScene)
    }
    
    // MARK: Duration UI
    
    private var duration: Double = 2
    private let durationLabel = UILabel.default(fontSize: 21)
    private let durationStepper = UIStepper.default(minVal: 1, maxVal: 1000)
    private func setupDurationContent() {
        durationLabel.text = "Duration: \(Int(duration)) sec."
        durationStepper.value = duration
        durationStepper.addTarget(self, action: #selector(CircularProgressViewController.durationTapped(_:)), for: .primaryActionTriggered)
        addPairToContentStack(firstView: durationLabel, secondView: durationStepper)
    }
    
    @objc private func durationTapped(_ sender: UIStepper) {
        duration = sender.value
        durationLabel.text = "Duration: \(Int(duration)) sec."
    }
    
    // MARK: Progress UI
    
    private var progress: CGFloat = 0.5
    private let progressLabel = UILabel.default(fontSize: 21)
    private let progressTextField: UITextField = {
        let progressTextField = UITextField()
        progressTextField.translatesAutoresizingMaskIntoConstraints = false
        progressTextField.borderStyle = .roundedRect
        progressTextField.backgroundColor = .white
        progressTextField.textAlignment = .center
        progressTextField.tintColor = .darkBlue
        progressTextField.textColor = .darkBlue
        progressTextField.keyboardType = .decimalPad
        

        return progressTextField
    }()
    private func setupProgressContent() {
        updateProgressContent()
        progressTextField.addTarget(self, action: #selector(CircularProgressViewController.progressEditingDidEnd(_:)), for: .editingDidEnd)
        addPairToContentStack(firstView: progressLabel, secondView: progressTextField)
    }
    
    @objc private func progressEditingDidEnd(_ sender: UITextField) {
        let commaFilteredInput = sender.text!.replacingOccurrences(of: ",", with: ".")
        
        if let textAsNumber = Float(commaFilteredInput) {
            if textAsNumber > 100 {
                progress = 1
            } else if textAsNumber < 0 {
                progress = 0
            } else {
                progress = CGFloat(textAsNumber / 100)
            }
        }
        
        updateProgressContent()
    }
    
    private func updateProgressContent() {
        let printableProgress = String(format: "%.2f",
                                       progress * 100)
        progressLabel.text = "Progress: \(printableProgress)%"
        
        progressTextField.text = printableProgress
    }
    
    // MARK: Clockwise UI
    
    private var clockwise = true
    private let clockwiseLabel = UILabel.default(fontSize: 21, text: "Clockwise")
    private let clockwiseSwitch = UISwitch.default()
    private func setupClockwiseContent() {
        clockwiseSwitch.setOn(clockwise, animated: false)
        clockwiseSwitch.addTarget(self, action: #selector(CircularProgressViewController.clockwiseTapped), for: .primaryActionTriggered)
        addPairToContentStack(firstView: clockwiseLabel, secondView: clockwiseSwitch)
    }
    
    @objc private func clockwiseTapped() {
        clockwise = clockwiseSwitch.isOn
    }
    
    // MARK: Animate Button Behavior

    @objc private func animateTapped(_ sender: UIButton) {
        switch state {
        case .animating:
            state = .paused
            sender.setTitle("Continue", for: .normal)
            progressScene.isPaused = true
            
        case .paused:
            state = .animating
            sender.setTitle("Pause", for: .normal)
            progressScene.isPaused = false
            
        case .stopped:
            state = .animating
            sender.setTitle("Pause", for: .normal)
            
            progressScene.progress.clockwise = clockwise
            progressScene.progress.updateProgress(progress, duration: TimeInterval(duration)) {
                sender.setTitle("Animate", for: .normal)
                self.state = .stopped
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateButton.addTarget(self, action: #selector(CircularProgressViewController.animateTapped(_:)), for: .primaryActionTriggered)
        
        setupProgress()
        
        setupDurationContent()
        setupProgressContent()
        setupClockwiseContent()
    }
}
