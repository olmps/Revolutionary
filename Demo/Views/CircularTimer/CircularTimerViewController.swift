//
//  CircularTimerViewController.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 25/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularTimerViewController: UIViewController {
    
    private var duration: Int = 0 { didSet { updateDurationLabel() } }
    @IBOutlet private weak var durationLabel: UILabel!
    
    private var revolutions: Int = 0 { didSet { updateRevolutionsLabel() } }
    @IBOutlet private weak var revolutionsLabel: UILabel!
    
    private var clockwise: Bool = true
    
    private var skview: SKView!
    private var circularTimerScene: CircularTimerScene!
    @IBOutlet private weak var skViewWrapper: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        duration = 6
        revolutions = 3
        
        skview = SKView(frame: skViewWrapper.frame)
        skViewWrapper.addSubview(skview)
        
        circularTimerScene = CircularTimerScene(size: skview.bounds.size)
        skview.presentScene(circularTimerScene)
        skview.showsDrawCount = true
        skview.showsNodeCount = true
    }
    
    @IBAction private func durationStepperTapped(_ sender: UIStepper) {
        duration = Int(sender.value)
    }
    
    @IBAction private func revolutionsStepperTapped(_ sender: UIStepper) {
        revolutions = Int(sender.value)
    }
    
    @IBAction private func clockwiseSwitchTapped(_ sender: UISwitch) {
        clockwise = sender.isOn
    }
    
    @IBAction private func animateTapped(_ sender: UIButton) {
        circularTimerScene.animate(withDuration: duration,
                                   revolutions: revolutions,
                                   clockwise: clockwise)
    }
    
    private func updateDurationLabel() {
        durationLabel.text = "Rev. Duration: \(duration) sec."
    }
    
    private func updateRevolutionsLabel() {
        revolutionsLabel.text = "Revolutions: \(revolutions)x"
    }
}
