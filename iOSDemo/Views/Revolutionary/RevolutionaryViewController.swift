//
//  RevolutionaryViewController.swift
//  iOSDemo
//
//  Created by Guilherme Carlos Matuella on 22/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

class RevolutionaryViewController: UIViewController {
    
    private enum State {
        
        case progress
        case timer
    }
    
    // MARK: - Shared Properties
    
    /// Property used to managed what's appearing in the VC, given the selected content on the segment control
    private var state: State = .progress {
        didSet {
            switch state {
            case .progress:
                revolutionary.reset()
                progressContentView.isHidden = false
                timerContentView.isHidden = true
            case .timer:
                revolutionary.reset(completed: isCountdown)
                progressContentView.isHidden = true
                timerContentView.isHidden = false
            }
        }
    }
    
    @IBOutlet private weak var contentSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var animateButton: UIButton!
    
    @IBOutlet private weak var revolutionaryViewWrapper: UIView!
    private var revolutionary: Revolutionary!
    
    // MARK: - Progress Content Properties
    
    private let progressContentView = UIView(translatingAutoresizingMaskIntoConstraints: false)
    
    private var duration = 3 {
        didSet { updateDuration() }
    }
    private let durationLabel = UILabel.instanceWithDefaultProperties()
    private let durationStepper = UIStepper.instanceWithDefaultProperties()
    
    private var progress: CGFloat = 0 {
        didSet { updateProgress() }
    }
    private let progressLabel = UILabel.instanceWithDefaultProperties()
    private let progressTextField = UITextField.instanceWithDefaultProperties()
    
    // MARK: - Timer Content Properties
    
    private let timerContentView = UIView(translatingAutoresizingMaskIntoConstraints: false)
    
    private var revolutionDuration = 3 {
        didSet { updateRevolutionDuration() }
    }
    private let revolutionDurationLabel = UILabel.instanceWithDefaultProperties()
    private let revolutionDurationStepper = UIStepper.instanceWithDefaultProperties()
    
    private var revolutionsAmount = 3 {
        didSet { updateRevolutionsAmount() }
    }
    private let revolutionsAmountLabel = UILabel.instanceWithDefaultProperties()
    private let revolutionsAmountStepper = UIStepper.instanceWithDefaultProperties()
    
    private var endless = false {
        didSet {
            revolutionsAmountStepper.isEnabled = !endless
            
            if endless {
                revolutionsAmountLabel.alpha = 0.5
                revolutionsAmountStepper.alpha = 0.5
            } else {
                revolutionsAmountLabel.alpha = 1
                revolutionsAmountStepper.alpha = 1
            }
        }
    }
    private let endlessLabel = UILabel.instanceWithDefaultProperties(withText: "Endless")
    private let endlessSwitch: UISwitch = {
        let endlessSwitch = UISwitch()
        endlessSwitch.onTintColor = .coolPurple
        endlessSwitch.setOn(false, animated: false)
        
        endlessSwitch.translatesAutoresizingMaskIntoConstraints = false
        return endlessSwitch
    }()
    
    private var isCountdown = true {
        didSet { revolutionary.reset(completed: isCountdown) }
    }
    private let timerStyleLabel = UILabel.instanceWithDefaultProperties(withText: "Style")
    private let timerStyleSegment: UISegmentedControl = {
        let timerStyleSegment = UISegmentedControl(items: ["Countdown", "Stopwatch"])
        timerStyleSegment.tintColor = .coolPurple
        timerStyleSegment.selectedSegmentIndex = 0
        
        timerStyleSegment.translatesAutoresizingMaskIntoConstraints = false
        return timerStyleSegment
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        view.addDismissKeyboard()
        
        duration = Int(durationStepper.value)
        
        setupRevolutionary()
        setupProgressContent()
        setupTimerContent()
        
        timerContentView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let propertiesVC = segue.destination as! PropertiesViewController
        propertiesVC.delegate = self
        propertiesVC.configureUI(withRevolutionaryState: revolutionary)
    }
    
    @IBAction private func swappedContent(_ sender: UISegmentedControl) {
        state = sender.selectedSegmentIndex == 0 ? .progress : .timer
    }
}

// MARK - Revolutionary Content

extension RevolutionaryViewController {
    
    private func setupRevolutionary() {
        //You can instantiate the `Revolutionary` by using a builder
        let revolutionaryBuilder = RevolutionaryBuilder { builder in
            //Customize properties here
            //I.E.:
            builder.mainArcColor = .coolPurple
            builder.mainArcWidth = 10
            builder.backgroundArcWidth = 10
            
            builder.displayStyle = .percentage(decimalPlaces: 2)
        }
        
        let revolutionaryView = RevolutionaryView(revolutionaryBuilder, frame: revolutionaryViewWrapper.bounds)
        
        //or by calling a default init with its default properties
        //let revolutionaryView = RevolutionaryView(frame: revolutionaryViewWrapper.bounds)
        
        revolutionaryView.translatesAutoresizingMaskIntoConstraints = false
        revolutionaryViewWrapper.addSubview(revolutionaryView)
        revolutionaryView.leadingAnchor.constraint(equalTo: revolutionaryViewWrapper.leadingAnchor, constant: 0).isActive = true
        revolutionaryView.trailingAnchor.constraint(equalTo: revolutionaryViewWrapper.trailingAnchor, constant: 0).isActive = true
        revolutionaryView.topAnchor.constraint(equalTo: revolutionaryViewWrapper.topAnchor, constant: 0).isActive = true
        revolutionaryView.bottomAnchor.constraint(equalTo: revolutionaryViewWrapper.bottomAnchor, constant: 0).isActive = true
        
        //Because Revolutionary is a SKNode, we must stay with its reference to manipulate its state
        revolutionary = revolutionaryView.rev
        
        //If you don't want to create a custom `SKLabel` on the builder, just customize the default one after instantiation. I.e:
        revolutionary.displayLabel.fontColor = .coolPurple
    }
    
    @IBAction private func animateTapped(_ sender: UIButton) {
        if revolutionary.isPaused { revolutionary.resume() }
        
        switch state {
        case .progress: animateProgressState()
        case .timer: animateTimerState()
        }
    }
    
    private func animateProgressState() {
        revolutionary.run(toProgress: progress, withDuration: Double(duration)) {
            print("Completed Progress")
        }
    }
    
    private func animateTimerState() {
        let parsedRevDuration = Double(revolutionDuration)
        
        if endless {
            if isCountdown {
                revolutionary.runCountdownIndefinitely(withRevolutionDuration: parsedRevDuration)
            } else {
                revolutionary.runStopwatchIndefinitely(withRevolutionDuration: parsedRevDuration)
            }
        } else {
            if isCountdown {
                revolutionary.runCountdown(withRevolutionDuration: parsedRevDuration, amountOfRevolutions: revolutionsAmount) {
                    print("Completed Countdown revolutions")
                }
            } else {
                revolutionary.runStopwatch(withRevolutionDuration: parsedRevDuration, amountOfRevolutions: revolutionsAmount) {
                    print("Completed Stopwatch revolutions")
                }
            }
        }
    }
    
    @IBAction private func pauseTapped(_ sender: UIButton) {
        //Alternativelly, you could set `isPaused` directly. Just for clear use of the API, these redundant funcs were created.
        if revolutionary.isPaused {
            sender.setTitle("PAUSE", for: .normal)
            revolutionary.resume()
        } else {
            sender.setTitle("RESUME", for: .normal)
            revolutionary.pause()
        }
    }
    
    @IBAction private func resetTapped(_ sender: UIButton) {
        if state == .timer {
            revolutionary.reset(completed: isCountdown)
        } else {
            revolutionary.reset()
        }
        
        progress = 0
    }
}

extension RevolutionaryViewController: PropertiesDelegate {
    
    func properties(_ properties: PropertiesViewController, updatedStyle displayStyle: Revolutionary.DisplayStyle) {
        revolutionary.displayStyle = displayStyle
    }
    
    func properties(_ properties: PropertiesViewController, updatedClockwise clockwise: Bool) {
        revolutionary.clockwise = clockwise
    }
    
    func properties(_ properties: PropertiesViewController, updatedAnimationMultiplier animationMultiplier: Int) {
        revolutionary.animationMultiplier = animationMultiplier
    }
    
    func properties(_ properties: PropertiesViewController, updatedBackgroundArc hasBackgroundArc: Bool) {
        revolutionary.hasBackgroundArc = hasBackgroundArc
    }
    
    func properties(_ properties: PropertiesViewController, updatedMainArcColor mainArcColor: UIColor) {
        revolutionary.mainArcColor = mainArcColor
    }
    
    func properties(_ properties: PropertiesViewController, updatedBackgroundArcColor backgroundArcColor: UIColor) {
        revolutionary.backgroundArcColor = backgroundArcColor
    }
    
    func properties(_ properties: PropertiesViewController, updatedMainArcWidth mainArcWidth: CGFloat) {
        revolutionary.mainArcWidth = mainArcWidth
    }
    
    func properties(_ properties: PropertiesViewController, updatedBackgroundArcWidth backgroundArcWidth: CGFloat) {
        revolutionary.backgroundArcWidth = backgroundArcWidth
    }
    
    func properties(_ properties: PropertiesViewController, updatedMainArcLineCap mainArcLineCap: CGLineCap) {
        revolutionary.mainArcLineCap = mainArcLineCap
    }
    
    func properties(_ properties: PropertiesViewController, updatedBackgroundArcLineCap backgroundArcLineCap: CGLineCap) {
        revolutionary.backgroundArcLineCap = backgroundArcLineCap
    }
}

// MARK - Progress Segment Content

extension RevolutionaryViewController {
    
    private func setupProgressContent() {
        view.addSubview(progressContentView)
        progressContentView.addSubviews([durationLabel, durationStepper, progressLabel, progressTextField])
        
        durationLabel.leadingAnchor.constraint(equalTo: progressContentView.leadingAnchor, constant: 0).isActive = true
        durationLabel.trailingAnchor.constraint(equalTo: durationStepper.leadingAnchor, constant: 8).isActive = true
        durationLabel.centerYAnchor.constraint(equalTo: durationStepper.centerYAnchor).isActive = true
        
        durationStepper.trailingAnchor.constraint(equalTo: progressContentView.trailingAnchor, constant: 0).isActive = true
        durationStepper.topAnchor.constraint(equalTo: progressContentView.topAnchor, constant: 0).isActive = true
        
        progressLabel.leadingAnchor.constraint(equalTo: progressContentView.leadingAnchor, constant: 0).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: progressTextField.leadingAnchor, constant: 8).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: progressTextField.centerYAnchor).isActive = true
        
        progressTextField.leadingAnchor.constraint(equalTo: durationStepper.leadingAnchor, constant: 0).isActive = true
        progressTextField.trailingAnchor.constraint(equalTo: progressContentView.trailingAnchor, constant: 0).isActive = true
        progressTextField.topAnchor.constraint(equalTo: durationStepper.bottomAnchor, constant: 8).isActive = true
        progressTextField.bottomAnchor.constraint(equalTo: progressContentView.bottomAnchor, constant: 0).isActive = true
        
        progressContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        progressContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        progressContentView.topAnchor.constraint(equalTo: contentSegmentedControl.bottomAnchor, constant: 16).isActive = true
        
        updateDuration()
        updateProgress()
        
        durationStepper.addTarget(self, action: #selector(RevolutionaryViewController.durationStepperTapped), for: .primaryActionTriggered)
        progressTextField.addTarget(self, action: #selector(RevolutionaryViewController.progressEditingDidEnd), for: .editingDidEnd)
    }
    
    @objc private func durationStepperTapped() {
        duration = Int(durationStepper.value)
    }
    
    private func updateDuration() {
        durationLabel.text = "Duration: \(duration) sec."
    }
    
    @objc private func progressEditingDidEnd() {
        let commaFilteredInput = progressTextField.text!.replacingOccurrences(of: ",", with: ".")
        
        guard let textAsNumber = Float(commaFilteredInput) else {
            updateProgress()
            return
        }
        
        switch textAsNumber {
        case let progressValue where progressValue > 100: progress = 1
        case let progressValue where progressValue < 0: progress = 0
        default: progress = CGFloat(textAsNumber / 100)
        }
    }
    
    private func updateProgress() {
        let printableProgress = String(format: "%.2f", progress * 100)
        progressLabel.text = "Progress: \(printableProgress)%"
        
        progressTextField.text = printableProgress
    }
}

// MARK: - Timer Segment Content

extension RevolutionaryViewController {
    
    private func setupTimerContent() {
        view.addSubview(timerContentView)
        timerContentView.addSubviews([revolutionDurationLabel, revolutionDurationStepper, revolutionsAmountLabel, revolutionsAmountStepper,
                                      endlessLabel, endlessSwitch, timerStyleLabel, timerStyleSegment])
        
        revolutionDurationLabel.leadingAnchor.constraint(equalTo: timerContentView.leadingAnchor, constant: 0).isActive = true
        revolutionDurationLabel.trailingAnchor.constraint(equalTo: revolutionDurationStepper.leadingAnchor, constant: 8).isActive = true
        revolutionDurationLabel.centerYAnchor.constraint(equalTo: revolutionDurationStepper.centerYAnchor).isActive = true
        
        revolutionDurationStepper.trailingAnchor.constraint(equalTo: timerContentView.trailingAnchor, constant: 0).isActive = true
        revolutionDurationStepper.topAnchor.constraint(equalTo: timerContentView.topAnchor, constant: 0).isActive = true
        
        revolutionsAmountLabel.leadingAnchor.constraint(equalTo: timerContentView.leadingAnchor, constant: 0).isActive = true
        revolutionsAmountLabel.trailingAnchor.constraint(equalTo: revolutionsAmountStepper.leadingAnchor, constant: 8).isActive = true
        revolutionsAmountLabel.centerYAnchor.constraint(equalTo: revolutionsAmountStepper.centerYAnchor).isActive = true
        
        revolutionsAmountStepper.trailingAnchor.constraint(equalTo: timerContentView.trailingAnchor, constant: 0).isActive = true
        revolutionsAmountStepper.topAnchor.constraint(equalTo: revolutionDurationStepper.bottomAnchor, constant: 8).isActive = true
        
        endlessLabel.leadingAnchor.constraint(equalTo: timerContentView.leadingAnchor, constant: 0).isActive = true
        endlessLabel.trailingAnchor.constraint(equalTo: endlessSwitch.leadingAnchor, constant: 8).isActive = true
        endlessLabel.centerYAnchor.constraint(equalTo: endlessSwitch.centerYAnchor).isActive = true
        
        endlessSwitch.trailingAnchor.constraint(equalTo: timerContentView.trailingAnchor, constant: 0).isActive = true
        endlessSwitch.topAnchor.constraint(equalTo: revolutionsAmountStepper.bottomAnchor, constant: 8).isActive = true
        
        timerStyleLabel.leadingAnchor.constraint(equalTo: timerContentView.leadingAnchor, constant: 0).isActive = true
        timerStyleLabel.trailingAnchor.constraint(equalTo: timerStyleSegment.leadingAnchor, constant: 8).isActive = true
        timerStyleLabel.centerYAnchor.constraint(equalTo: timerStyleSegment.centerYAnchor).isActive = true
        
        timerStyleSegment.trailingAnchor.constraint(equalTo: timerContentView.trailingAnchor, constant: 0).isActive = true
        timerStyleSegment.topAnchor.constraint(equalTo: endlessSwitch.bottomAnchor, constant: 8).isActive = true
        timerStyleSegment.bottomAnchor.constraint(equalTo: timerContentView.bottomAnchor, constant: 0).isActive = true
        timerStyleSegment.setContentHuggingPriority(.required, for: .horizontal)
        
        timerContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        timerContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        timerContentView.topAnchor.constraint(equalTo: contentSegmentedControl.bottomAnchor, constant: 16).isActive = true
        
        revolutionDurationStepper.addTarget(self, action: #selector(RevolutionaryViewController.revolutionDurationStepperTapped), for: .primaryActionTriggered)
        revolutionsAmountStepper.addTarget(self, action: #selector(RevolutionaryViewController.revolutionsAmountStepperTapped), for: .primaryActionTriggered)
        endlessSwitch.addTarget(self, action: #selector(RevolutionaryViewController.endlessSwitchTapped), for: .primaryActionTriggered)
        timerStyleSegment.addTarget(self, action: #selector(RevolutionaryViewController.timerSegmentTapped), for: .primaryActionTriggered)
        
        updateRevolutionDuration()
        updateRevolutionsAmount()
    }
    
    @objc private func revolutionDurationStepperTapped() {
        revolutionDuration = Int(revolutionDurationStepper.value)
    }
    
    private func updateRevolutionDuration() {
        revolutionDurationLabel.text = "Rev. Duration: \(revolutionDuration) sec."
    }
    
    @objc private func revolutionsAmountStepperTapped() {
        revolutionsAmount = Int(revolutionsAmountStepper.value)
    }
    
    private func updateRevolutionsAmount() {
        revolutionsAmountLabel.text = "Revolutions: \(revolutionsAmount)x"
    }
    
    @objc private func endlessSwitchTapped() {
        endless = endlessSwitch.isOn
    }
    
    @objc private func timerSegmentTapped() {
        isCountdown = timerStyleSegment.selectedSegmentIndex == 0
    }
}
