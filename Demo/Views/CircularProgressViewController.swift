//
//  CircularProgressViewController.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 22/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

private struct V {
    static let outsidePadding: CGFloat = 16
    static let innerPadding: CGFloat = 8
}

class CircularProgressViewController: UIViewController {
    
    private var superviewHeight: CGFloat {
        return view.bounds.height
    }
    
    private var superviewWidth: CGFloat {
        return view.bounds.width
    }
    
    // UI Elements
    
    // MARK: SKView Contents
    private let progressScene = ProgressScene()
    private let skView: SKView = {
        let skView = SKView()
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        return skView
    }()
    private func setupSKView() {
        view.addSubview(skView)
        skView.edgesToSuperview(excluding: .bottom)
        skView.heightToSuperview(multiplier: 0.5)
        
        skView.layoutIfNeeded()
        
        progressScene.size = skView.bounds.size
        progressScene.configure(CircularProgressBuilder {
            let smallestSide = superviewHeight > superviewWidth ? superviewWidth : superviewHeight
            $0.circleRadius = smallestSide / 2.5
            $0.circleLineWidth = 10
            $0.displayStyle = .compactedRemainingTime
            $0.circleColor = .white
        })
        
        skView.presentScene(progressScene)
    }
    
    // MARK: ScrollView + StackView Wrapper
    
    private let scrollViewWrapper: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .brown
        scrollView.keyboardDismissMode = .onDrag
        scrollView.isScrollEnabled = true
        
        return scrollView
    }()
    private func setupScrollView() {
        view.addSubview(scrollViewWrapper)
        
        scrollViewWrapper.edgesToSuperview(excluding: [.top, .bottom])
        scrollViewWrapper.topToBottom(of: skView, offset: V.outsidePadding)
        scrollViewWrapper.bottomToSuperview(offset: V.outsidePadding)
        scrollViewWrapper.contentInsetAdjustmentBehavior = .never
    }
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = V.outsidePadding
        
        return stackView
    }()
    private func setupVerticalStackView() {
        scrollViewWrapper.addSubview(verticalStackView)
        verticalStackView.widthToSuperview(relation: .equalOrGreater)

        verticalStackView.edgesToSuperview()
    }
    
    // MARK: Duration UI
    
    private let durationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    private let durationLabel: UILabel = {
        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return durationLabel
    }()
    private let durationStepper: UIStepper = {
        let durationStepper = UIStepper()
        durationStepper.translatesAutoresizingMaskIntoConstraints = false
        
        durationStepper.minimumValue = 0
        durationStepper.value = 2
        durationStepper.maximumValue = 1000
        
        return durationStepper
    }()
    private func setupDurationStackView() {
        verticalStackView.addArrangedSubview(durationStackView)
        
        durationStackView.addArrangedSubview(durationLabel)
        durationLabel.leadingToSuperview()
        
        durationStackView.addArrangedSubview(durationStepper)
        durationStepper.trailingToSuperview()
        
        durationStepper.addTarget(self, action: #selector(CircularProgressViewController.durationStepperTapped(_:)), for: .primaryActionTriggered)
    }
    
    @objc private func durationStepperTapped(_ sender: UIStepper) {
        let stepValue = sender.value > Double(duration) ? sender.stepValue : -sender.stepValue
        
        if state == .animating {
            progressScene.progress.updateDuration(stepValue)
        }
        
        duration += Int(stepValue)
    }
    
    // MARK: Progress UI
    
    private let progressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    private let progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return progressLabel
    }()
    private let progressTextField: UITextField = {
        let progressTextField = UITextField()
        progressTextField.translatesAutoresizingMaskIntoConstraints = false
        progressTextField.borderStyle = .roundedRect
        progressTextField.backgroundColor = .white
        progressTextField.textAlignment = .center
        
        return progressTextField
    }()
    private func setupProgressStackView() {
        verticalStackView.addArrangedSubview(progressStackView)
        
        progressStackView.addArrangedSubview(progressLabel)
        progressLabel.leadingToSuperview()
        
        progressStackView.addArrangedSubview(progressTextField)
        progressTextField.trailingToSuperview()
        progressTextField.width(to: durationStepper)
        
        progressTextField.addTarget(self, action: #selector(CircularProgressViewController.progressEditingDidEnd(_:)), for: .editingDidEnd)
    }
    
    @objc private func progressEditingDidEnd(_ sender: UITextField) {
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
    
    // MARK: Clockwise UI
    
    private let clockwiseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    private let clockwiseLabel: UILabel = {
        let clockwiseLabel = UILabel()
        clockwiseLabel.translatesAutoresizingMaskIntoConstraints = false
        clockwiseLabel.text = "Clockwise"
        
        return clockwiseLabel
    }()
    private let clockwiseSwitch: UISwitch = {
        let clockwiseSwitch = UISwitch()
        clockwiseSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        return clockwiseSwitch
    }()
    private func setupClockwiseStackView() {
        verticalStackView.addArrangedSubview(clockwiseStackView)
        
        clockwiseStackView.addArrangedSubview(clockwiseLabel)
        clockwiseLabel.leadingToSuperview()
        
        clockwiseStackView.addArrangedSubview(clockwiseSwitch)
        clockwiseSwitch.trailingToSuperview()
        
        clockwiseSwitch.addTarget(self, action: #selector(CircularProgressViewController.clockwiseSwitchTapped(_:)), for: .primaryActionTriggered)
    }
    
    @objc private func clockwiseSwitchTapped(_ sender: UISwitch) {
        clockwise = sender.isOn
    }
    
    // MARK: Animate Button UI
    
    private let animateButton: UIButton = {
        let animateButton = UIButton()
        animateButton.translatesAutoresizingMaskIntoConstraints = false
        animateButton.setTitle("Animate", for: .normal)
        
        animateButton.setTitleColor(.white, for: .normal)
        animateButton.setImage(UIImage.image(withColor: .cyan), for: .normal)
        
        animateButton.setTitleColor(.black, for: .highlighted)
        animateButton.setImage(UIImage.image(withColor: .blue), for: .highlighted)
        
        return animateButton
    }()
    private func setupAnimateButton() {
        view.addSubview(animateButton)
        
        animateButton.height(40)
        animateButton.widthToSuperview(multiplier: 0.5)
        animateButton.centerXToSuperview()
        animateButton.topToBottom(of: verticalStackView, offset: V.outsidePadding * 3)
        
        animateButton.addTarget(self, action: #selector(CircularProgressViewController.animateTapped(_:)), for: .primaryActionTriggered)
    }
    
    
    @objc private func animateTapped(_ sender: UIButton) {
        progressScene.progress.circleColor = .random
        
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
    
    // MARK: UI Auxiliar Properties
    
    private var duration: Int = 0 { didSet { updateDurationLabel() } }
    private func updateDurationLabel() {
        durationLabel.text = "Duration: \(duration) sec."
    }
    
    private var progress: CGFloat = 0 { didSet { updateProgress() } }
    private func updateProgress() {
        let printableProgress = String(format: "%.2f",
                                       progress * 100)
        progressLabel.text = "Progress: \(printableProgress)%"
        
        progressTextField.text = printableProgress
    }
    
    private enum State {
        case animating
        case paused
        case stopped
    }
    private var state = State.stopped
    
    private var clockwise: Bool = true
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //Default Values
        duration = Int(durationStepper.value)
        progress = 0.5
        
        addDismissTap()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
        
        setupSKView()
        
        setupScrollView()
        
        setupVerticalStackView()
        setupDurationStackView()
        setupProgressStackView()
        setupClockwiseStackView()
        
        setupAnimateButton()
    }
}

extension UIViewController {
    
    func addDismissTap() {
        let dismissTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(dismissTap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImage {
    static func image(withColor color: UIColor) -> UIImage {
        let smallestSize = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(smallestSize, false, 1)
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: smallestSize))
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return colorizedImage!
    }
}
