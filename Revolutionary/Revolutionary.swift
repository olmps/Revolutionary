//
//  Revolutionary.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit
import os.log

/// Wrapper dedicated to contain magic numbers or strings
private struct V {
    
    static let animationKey = "circularProgressAnimation"
    
    static let fullRevolution: CGFloat = .pi * 2
    
    static let minProgress: CGFloat = 0
    static let maxProgress: CGFloat = 1
}

/**
 The core class of the `Revolutionary` lib - clearly obvious enough.
 
 Its API is available in 3 different types of "flows" (or "runs", which was the prefix used before each "flow" execution):
 
 # 1. Animating a progress directly.
 Explanation: Exemplifying, say you want to animate a percentage of something being downloaded, so you would call
 `run(progress:, duration:, completion:)` and just pass the desired progress of your download, also informing the duration in which it should conclude
 the animation).
 
 # 2. Animating a countdown or stopwatch with a specific amount of revolutions.
 Explanation: You want to create a scenario where the arcs need to behave like a countdown/stopwatch, but its future is predetermined, so you would pass a
 amount of revolutions and how much time each revolution should take. To create these scenarios, call both
 `runCountdown(revolutionDuration:, amountOfRevolutions:, completion:)` and `runStopwatch(revolutionDuration:, amountOfRevolutions:, completion:)`
 
 # 3. Animating a countdown or stopwatch indefinitely.
 Explanation: Cases where no specific amount of revolutions is needed, this behavior provides no completion, because it's intended to not stop until requested.
 Just call both `runCountdownIndefinitely(revolutionDuration:)` and `runStopwatchIndefinitely(revolutionDuration:)`, and to stop it, call `stopRunGracefully()`
 (which will stop on the completion of the next revolution) or `reset(completed:)`.
 
 It's important to know that what the countdown means here is just starting from 100% and finishing its revolution in 0%. The stopwatch is the contrary, starts
 in 0% and goes to 100%. Both directions can be manipulated by `clockwise`.
 
 ---
 # IMPORTANT
 
 These `run`/"flows" has UI properties exposed to be customized, and these properties will probably cover most of the scenarios.
 If your scenario is not included, this is just a `SKNode` after all, so manipulate the positions, sizes, child nodes at will.
 
 It's important to specify one UI property in question, because it's the only complex one, and that is `displayLabel` which uses a `displayStyle` to manipulate
 the text inside the `SKLabel` that is going to appear in the center of both `mainArc` and `backgroundArc`.
 See `Revolutionary.DisplayStyle` to know more about the possibilities.
 */
public class Revolutionary: SKNode {
    
    /**
     The content that is going to appear mid-animation, in the center of the `Revolutionary` arcs.
     
     If needed, the `displayLabel` - which the `displayStyle` modifies the text - is public and exposed to any UI modification.
     
     - FIXME: Both `elapsedTime` and `remainingTime` cases use a `DateComponentsFormatter` which has its API broken and mess it up when using `.nanosecond` in
     its `allowedUnits` property. Also, a mix of `collapsesLargestUnit` and `allowsFractionalUnits` also does not work properly - really messy stuff!
     Find a workaround or try to solve this API directly.
     */
    public enum DisplayStyle: Equatable {
        
        /// Nothing will be displayed
        case none
        
        /// The current progress percentage with the granularity based on the `decimalPlaces`
        case percentage(decimalPlaces: Int)
        
        /// The elapsed time given the `DateComponentsFormatter` format
        case elapsedTime(formatter: DateComponentsFormatter)
        
        /// The remaining time given the `DateComponentsFormatter` format
        case remainingTime(formatter: DateComponentsFormatter)
        
        /// A custom formatted string
        case custom(text: String)
    }
    
    // MARK: - Main Arc Properties
    
    private lazy var mainArc: SKShapeNode = {
        let mainArc = SKShapeNode()
        
        mainArc.zRotation = .pi / 2
        mainArc.strokeColor = mainArcColor
        mainArc.lineWidth = mainArcWidth
        mainArc.lineCap = mainArcLineCap
        
        return mainArc
    }()
    
    /// Defaults to `white`.
    public var mainArcColor: UIColor = .white {
        didSet { mainArc.strokeColor = mainArcColor }
    }
    
    /// Defaults to `5`.
    public var mainArcWidth: CGFloat = 5 {
        didSet { mainArc.lineWidth = mainArcWidth }
    }
    
    /// Defaults to `round`.
    public var mainArcLineCap: CGLineCap = .round {
        didSet { mainArc.lineCap = mainArcLineCap }
    }
    
    // MARK: - Background Arc Properties
    
    private lazy var backgroundArc: SKShapeNode = {
        let backgroundArc = SKShapeNode()
        backgroundArc.path = arcPath(withProgress: V.maxProgress)
        
        backgroundArc.zRotation = .pi / 2
        backgroundArc.strokeColor = backgroundArcColor
        backgroundArc.lineWidth = backgroundArcWidth
        backgroundArc.lineCap = backgroundArcLineCap
        
        return backgroundArc
    }()
    
    /// Defaults to `lightGray`.
    public var backgroundArcColor: UIColor = .lightGray {
        didSet { backgroundArc.strokeColor = backgroundArcColor }
    }
    
    /// Defaults to `5`.
    public var backgroundArcWidth: CGFloat = 5 {
        didSet { backgroundArc.lineWidth = backgroundArcWidth }
    }
    
    /// Defaults to `round`.
    public var backgroundArcLineCap: CGLineCap = .round {
        didSet { backgroundArc.lineCap = backgroundArcLineCap }
    }
    
    // MARK: - Display Properties
    
    /// Display style of the `displayLabel`. Defaults to `none`.
    public var displayStyle: DisplayStyle = .none {
        didSet { updateDisplay() }
    }
    
    /// Shows the state of the `Revolutionary` given the current `displayStyle` format.
    public var displayLabel: SKLabelNode = {
        let displayLabel = SKLabelNode()
        
        displayLabel.fontName = UIFont.systemFont(ofSize: 0, weight: .semibold).fontName
        displayLabel.fontSize = 30
        displayLabel.fontColor = .gray
        displayLabel.verticalAlignmentMode = .center
        displayLabel.horizontalAlignmentMode = .center
        
        return displayLabel
    }() {
        didSet { updateDisplay() }
    }
    
    // MARK: - Other UI Properties
    
    /// Radius of both main and background arc. Defaults to `5`.
    public var arcRadius: CGFloat {
        didSet { updateArcs() }
    }
    
    /// Manages the appearance of the background arc. Defaults to `true`.
    public var hasBackgroundArc: Bool = true {
        didSet { backgroundArc.isHidden = !hasBackgroundArc }
    }
    
    /// Orientation of the progress arc. Defaults to `true`.
    public var clockwise: Bool = true {
        didSet { updateArcs() }
    }
    
    public var isAnimating: Bool { return action(forKey: V.animationKey) != nil }
    
    // MARK: - State Management Properties

    /**
     The "animation visual accuracy multiplier".
     
     The `animationMultiplier` will affect directly the number of animations (or `SKAction`) generated in an arbitrary `TimeInterval`.
     
     The greater this number, less "stutter" will be apparent in the animation. The contrary is likewise.
     
     Defaults to `1000`, which is a reasonable amount of `SKAction` given the fact that in most cases it does not loses the aspect of "continous" animation
     and the keeping the performance at a decent level.
     */
    public var animationMultiplier = 1000
    
    /**
     Should be between 0 and 1 - every other value will be truncated to the next "valid" value.
     
     To update the progress, call `run(progress: duration: completion:)`.
     */
    public private(set) var currentProgress: CGFloat = 0 {
        didSet { updateDisplay() }
    }
    
    /// The remaining duration of the current run
    private var remainingDuration: TimeInterval = 0
    
    /// The elapsed duration of the current run
    private var elapsedDuration: TimeInterval = 0
    
    /// The remaining revolutions when the run is not endless (defined by a specific revolutions)
    private var remainingRevolutions = 0
    
    /// Flag that defines if the `Revolutionary` is in a endless state (running endlessly a countdown or a stopwatch)
    private var endlessRun = false

    /// Control if an endlessRun should stop on its next cicle completion
    private var shouldStopOnNextCicle = false
    
    // MARK: - Initializers
    
    /**
     - Parameters:
        - radius: radius of both arcs (main and background).
        - builder: builder with the desired properties that should be overriden.
     */
    required public init(withRadius radius: CGFloat, builder: RevolutionaryBuilder) {
        self.arcRadius = radius
        
        if let mainArcColor = builder.mainArcColor { self.mainArcColor = mainArcColor }
        if let mainArcWidth = builder.mainArcWidth { self.mainArcWidth = mainArcWidth }
        if let mainArcLineCap = builder.mainArcLineCap { self.mainArcLineCap = mainArcLineCap }

        if let hasBackgroundArc = builder.hasBackgroundArc { self.hasBackgroundArc = hasBackgroundArc }
        
        if let backgroundArcColor = builder.backgroundArcColor { self.backgroundArcColor = backgroundArcColor }
        if let backgroundArcWidth = builder.backgroundArcWidth { self.backgroundArcWidth = backgroundArcWidth }
        if let backgroundArcLineCap = builder.backgroundArcLineCap { self.backgroundArcLineCap = backgroundArcLineCap }
        
        if let displayStyle = builder.displayStyle { self.displayStyle = displayStyle }
        if let displayLabel = builder.displayLabel { self.displayLabel = displayLabel }
        
        if let clockwise = builder.clockwise { self.clockwise = clockwise }
        if let animationMultiplier = builder.animationMultiplier { self.animationMultiplier = animationMultiplier }
        
        super.init()
        
        commonInit(startsCompleted: builder.startsCompleted)
    }
    
    /**
     - Parameters:
        - radius: radius of both arcs (main and background).
        - startsCompleted: initial "position" of the main arc.
     */
    required public init(withRadius radius: CGFloat, startsCompleted: Bool = false) {
        self.arcRadius = radius
        super.init()
        
        commonInit(startsCompleted: startsCompleted)
    }
    
    private func commonInit(startsCompleted: Bool) {
        addChild(backgroundArc)
        backgroundArc.isHidden = !hasBackgroundArc
        
        addChild(mainArc)
        currentProgress = startsCompleted ? V.maxProgress : V.minProgress
        updateArcs()
        
        addChild(displayLabel)
        updateDisplay()
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Core Behavior
    
    /**
     Updates the current progress of the `Revolutionary`.
     
     The proposed solution goes like this:
     1. It starts dividing the `duration` the total amount of `animationMultipler`, that will be used to space out the path "animations".
     2. After this, the `progress` sent as a parameter is used to calculate a diff with the `currentProgress`, so the new arc path may be correctly calculated.
     3. Then the `SKAction`s are created to evenly space the path changes in a `SKAction.run` closure, that updates all of the necessary properties.
     */
    private func update(progress: CGFloat, withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        //Variables to manage animations/properties state
        let animationTimespan = duration / TimeInterval(animationMultiplier)
        
        let progressDiff = newProgressDiff(progress)
        let parsedAnimationMultipler = CGFloat(animationMultiplier)
        let progressChangeUnit = progressDiff / parsedAnimationMultipler
        
        //Animations
        let modifyArcPath = SKAction.run {
            self.elapsedDuration += animationTimespan
            self.remainingDuration -= animationTimespan
            self.currentProgress += progressChangeUnit
            self.mainArc.path = self.arcPath(withProgress: self.currentProgress)
        }
        let waitNextModification = SKAction.wait(forDuration: animationTimespan)
        let arcModificationSequence = SKAction.sequence([waitNextModification, modifyArcPath])
        let repeatArcModifications = SKAction.repeat(arcModificationSequence, count: animationMultiplier)
        
        run(repeatArcModifications, withKey: V.animationKey) { completion?() }
    }
    
    /**
     Validates if a sent `progress` is contained within the specified range (0 for minimum and 1 for maximum).
     
     - Returns: a "normalized" progress.
     */
    private func validatedProgress(_ progress: CGFloat) -> CGFloat {
        switch progress {
        case let value where value < V.minProgress:
            if #available(iOS 12.0, *) {
                os_log(.fault, "Invalid progress sent to animate - Fixed by normalizing to %@. Requested: %@", V.minProgress, value)
            }
            return V.minProgress
        case let value where value > V.maxProgress:
            if #available(iOS 12.0, *) {
                os_log(.fault, "Invalid progress sent to animate - Fixed by normalizing to %@. Requested: %@", V.maxProgress, value)
            }
            return V.maxProgress
        default: return progress
        }
    }
    
    /**
     Calculates the difference between the progress sent as parameter and the `currentProgress`.
     
     It's important to notice that the difference is not in absolute values, meaning that if the parameter is smaller than the current, it will return a
     negative value.
     */
    private func newProgressDiff(_ newProgresss: CGFloat) -> CGFloat {
        let validatedProgress = self.validatedProgress(newProgresss)
        
        return validatedProgress - currentProgress
    }
    
    /**
     Uses the `progress` (from 0 to 1) to determine an arc that corresponds from 0 to 360 degress.
     
     - To build the arc radius, the property `arcRadius` is used.
     - To determine the arc orientation, the property `clockwise` is used.
     */
    private func arcPath(withProgress progress: CGFloat) -> CGPath? {
        guard progress > 0 else { return nil }
        
        let arcEndAngle = V.fullRevolution * progress
        
        //The "clockwise" is inverse in SpriteKit coordinates. See more at https://stackoverflow.com/a/36820789/8558606
        let clockwiseNormalizedEndAngle = clockwise ? arcEndAngle : -arcEndAngle
        let arcBezierPath = UIBezierPath(arcCenter: .zero, radius: arcRadius, startAngle: 0, endAngle: clockwiseNormalizedEndAngle, clockwise: clockwise)
        
        return arcBezierPath.cgPath
    }
}

// MARK: - State Management

public extension Revolutionary {
    
    /**
     Resets the progress (this reset will also stop the current ongoing animation).
     
     - Parameters:
     - completed: If the desired reset state is completed/`true` (progress = 1) or not/`false` (progress = 0). **Defaults to false**.
     */
    public func reset(completed: Bool = false) {
        removeAllActions()
        currentProgress = completed ? V.maxProgress : V.minProgress
        mainArc.path = arcPath(withProgress: currentProgress)
    }
    
    /// Resumes animations (sets the `SKNode.isPaused` property to `false`)
    public func resume() { isPaused = false }
    
    /// Pauses all ongoing animations (sets the `SKNode.isPaused` property to `true`)
    public func pause() { isPaused = true }
    
    public func setProgress(_ progress: CGFloat) {
        removeAllActions()
        currentProgress = validatedProgress(progress)
        mainArc.path = arcPath(withProgress: currentProgress)
    }
    
    /// Resets the internal state of possible runs
    private func resetState() {
        endlessRun = false
        remainingRevolutions = 0
        elapsedDuration = 0
        remainingDuration = 0
    }
    
    private func updateArcs() {
        mainArc.path = arcPath(withProgress: currentProgress)
        backgroundArc.path = arcPath(withProgress: V.maxProgress)
    }
}

// MARK: - Run Setups

extension Revolutionary {
    
    private func setupStopwatchRun() { reset(completed: false) }
    private func setupCountdownRun() { reset(completed: true) }
    
    /// Setups the run when it has a specific number of revolutions to end.
    private func setupFiniteRun(withRevolutionDuration revolutionDuration: TimeInterval, revolutions: Int) {
        //Reset state to ensure that if there is a running animation, it does not conflict
        resetState()
        
        remainingRevolutions = revolutions
        remainingDuration = revolutionDuration * Double(revolutions)
    }
    
    /// Setups the run when it has no predetermined revolutions.
    private func setupInfiniteRun(withRevolutionDuration revolutionDuration: TimeInterval) {
        //Reset state to ensure that if there is a running animation, it does not conflict
        resetState()
        
        endlessRun = true
        shouldStopOnNextCicle = false
    }
}

// MARK: - Finite Behavior

public extension Revolutionary {
    
    /**
     Runs from the `currentProgress` to the `progress` sent as parameter.
     
     - Parameters:
     - progress: the new progress. Accepted values are from 0 to 1 (representing the arc from 0 to 360 degress)
     - duration: the amount of time spent to animate the progress.
     - completion: an optional callback when the animation finishes.
     */
    public func run(toProgress progress: CGFloat, withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        setupFiniteRun(withRevolutionDuration: duration, revolutions: 1)
        
        update(progress: progress, withDuration: duration, completion: completion)
    }
    
    /**
     Runs a countdown style animation in a total `amountOfRevolutions` with each lasting a `revolutionDuration`.
     
     If a stop - in the middle of the animation - is needed, call `reset(completed:)`.
     */
    public func runCountdown(withRevolutionDuration revolutionDuration: TimeInterval, amountOfRevolutions: Int, completion: (() -> Void)? = nil) {
        setupFiniteRun(withRevolutionDuration: revolutionDuration, revolutions: amountOfRevolutions)
        setupCountdownRun()
        
        run(numberOfRevolutions: amountOfRevolutions, withDuration: revolutionDuration, finishesCompleted: false, completion: completion)
    }
    
    /**
     Runs a stopwatch style animation in a total `amountOfRevolutions` with each lasting a `revolutionDuration`.
     
     If a stop - in the middle of the animation - is needed, call `reset(completed:)`.
     */
    public func runStopwatch(withRevolutionDuration revolutionDuration: TimeInterval, amountOfRevolutions: Int, completion: (() -> Void)? = nil) {
        setupFiniteRun(withRevolutionDuration: revolutionDuration, revolutions: amountOfRevolutions)
        setupStopwatchRun()
        
        run(numberOfRevolutions: amountOfRevolutions, withDuration: revolutionDuration, finishesCompleted: true, completion: completion)
    }
    
    /**
     Recursively calls `update(progress: duration: completion:)` with a total of `numberOfRevolutions` times. Each call lasts the `duration` sent as parameter.
     
     - Parameters:
     - numberOfRevolutions: The total number of revolutions.
     - duration: The amount of time that each revolution will take to go from 0% to 100% (or 100% to 0%).
     - finishesCompleted: If it should finishes its last call by having the mainArc at 100% or 0%.
     - completion: Callback after the specific `duration` * `numberOfRevolutions` are finished.
     */
    private func run(numberOfRevolutions: Int, withDuration duration: TimeInterval, finishesCompleted: Bool, completion: (() -> Void)? = nil) {
        let targetProgress = finishesCompleted ? V.maxProgress : V.minProgress
        
        update(progress: targetProgress, withDuration: duration) {
            self.remainingRevolutions -= 1
            
            if self.remainingRevolutions == 0 {
                //If it's the last revolution, it should retain its state, so no need to reset
                completion?()
            } else {
                //The reset should always be opposite to the current progress, otherwise there will be no difference between the current,
                //and the one that is attributed in the targetProgress property.
                self.reset(completed: !finishesCompleted)
                self.run(numberOfRevolutions: numberOfRevolutions, withDuration: duration, finishesCompleted: finishesCompleted, completion: completion)
            }
        }
    }
}

// MARK: - Endless Behavior

public extension Revolutionary {
    
    /// When finishing the next cicle, stops the current indefinite run.
    public func stopRunGracefully() { shouldStopOnNextCicle = true }
    
    /**
     Runs a countdown style animation without a predetermined time to stop.
     
     To stop with a decent animation behavior, call `stopRunGracefully()`.
     If an instant reset is needed, call `reset(completed:)`.
     */
    public func runCountdownIndefinitely(withRevolutionDuration revolutionDuration: TimeInterval) {
        setupInfiniteRun(withRevolutionDuration: revolutionDuration)
        setupCountdownRun()
        
        runIndefinitely(withRevolutionDuration: revolutionDuration, finishesCompleted: false)
    }
    
    /**
     Runs a stopwatch style animation without a predetermined time to stop.
     
     To stop with a decent animation behavior, call `stopRunGracefully()`.
     If an instant reset is needed, call `reset(completed:)`.
     */
    public func runStopwatchIndefinitely(withRevolutionDuration revolutionDuration: TimeInterval) {
        setupInfiniteRun(withRevolutionDuration: revolutionDuration)
        setupStopwatchRun()
        
        runIndefinitely(withRevolutionDuration: revolutionDuration, finishesCompleted: true)
    }
    
    /**
     Recursively calls `update(progress: duration: completion:)` infinitely.
     Each call lasts the `duration` sent as parameter.
     
     - Parameters:
     - duration: The amount of time that each revolution will take to go from 0% to 100% (or 100% to 0%).
     - finishesCompleted: If it should finishes its last call by having the mainArc at 100% or 0%.
     */
    private func runIndefinitely(withRevolutionDuration duration: TimeInterval, finishesCompleted: Bool) {
        let targetProgress = finishesCompleted ? V.maxProgress : V.minProgress
        
        update(progress: targetProgress, withDuration: duration) {
            //The reset should always be opposite to the current progress, otherwise there will be no difference between the current,
            //and the one that is attributed in the targetProgress property.
            self.reset(completed: !finishesCompleted)
            
            if self.shouldStopOnNextCicle { return }
            self.runIndefinitely(withRevolutionDuration: duration, finishesCompleted: finishesCompleted)
        }
    }
}

// MARK: - Display Functions

public extension Revolutionary {
    
    /**
     Updates the `displayLabel` using the `displayStyle`.
     
     If the `displayStyle` is using an invalid `DateComponentsFormatter`, this function will throw a `fatalError(:)`.
     */
    private func updateDisplay() {
        displayLabel.isHidden = displayStyle == .none
        
        switch displayStyle {
        case .none: break
        case .percentage(let decimalPlaces):
            displayLabel.text = progressPercentage(withDecimalPlaces: decimalPlaces)
            
        case .elapsedTime(let formatter):
            guard let elapsedTimeDescription = formatter.string(from: elapsedDuration) else {
                fatalError("Bad `DateComponentsFormatter` sent to `Revolutionary.DisplayStyle.elapsedTime(formatter:)`")
            }
            
            displayLabel.text = elapsedTimeDescription
            
        case .remainingTime(let formatter):
            guard let remainingTimeDescription = formatter.string(from: remainingDuration) else {
                fatalError("Bad `DateComponentsFormatter` sent to `Revolutionary.DisplayStyle.remainingTime(formatter:)`")
            }
            
            displayLabel.text = remainingTimeDescription
        case .custom(let text):
            displayLabel.text = text
        }
    }
    
    private func progressPercentage(withDecimalPlaces decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f%%", currentProgress * 100)
    }
}
