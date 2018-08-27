//
//  CircularProgressViewController.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 22/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class CircularProgressViewController: UIViewController {

    private var duration: Int = 0 { didSet { updateDurationLabel() } }
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var durationStepper: UIStepper!
    
    private var progress: CGFloat = 0 { didSet { updateProgress() } }
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var progressTextField: UITextField!
    
    private var skview: SKView!
    private var circularProgressScene: CircularProgressScene!
    @IBOutlet private weak var skviewWrapper: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        duration = Int(durationStepper.value)
        progress = 0.5
        
        let dismissSelector = #selector(CircularProgressViewController.dismissKeyboard)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: dismissSelector)
        view.addGestureRecognizer(tap)
    }
    
    //Need to call on viewDidAppear because the `skviewWrapper`
    //does not contains its correct contentSize yet.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if skview == nil {
            skview = SKView(frame: skviewWrapper.frame)
            skviewWrapper.addSubview(skview)
            
            circularProgressScene = CircularProgressScene(size: skview.bounds.size)
            skview.presentScene(circularProgressScene)
            skview.showsDrawCount = true
            skview.showsNodeCount = true
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction private func durationStepperTapped(_ sender: UIStepper) {
        duration = Int(sender.value)
    }
    
    @IBAction private func progressEditingDidEnd(_ sender: UITextField) {
        let commaFilteredInput = sender.text!.replacingOccurrences(of: ",", with: ".")
        
        guard let textAsNumber = Float(commaFilteredInput) else {
            updateProgress()
            return
        }
        if textAsNumber > 100 {
            progress = 1
        } else if textAsNumber < 0 {
            progress = 0
        } else {
            progress = CGFloat(textAsNumber / 100)
        }
    }
    
    @IBAction private func animateTapped(_ sender: UIButton) {
        circularProgressScene.animateProgress(withDuration: duration,
                                              progress: progress)
    }
    
    private func updateDurationLabel() {
        durationLabel.text = "Duration: \(duration) sec."
    }
    
    private func updateProgress() {
        let printableProgress = String(format: "%.2f",
                                       progress * 100)
        progressLabel.text = "Progress: \(printableProgress)%"
        
        progressTextField.text = printableProgress
    }
}
