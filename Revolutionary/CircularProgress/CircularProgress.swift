//
//  CircularProgress.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

protocol CircularProgressDelegate: class {
    func circularProgress(_ circularProgress: CircularProgress,
                          updatedProgress progress: CGFloat,
                          withRemainingDuration remainingDuration: TimeInterval
                          )
}

//TODO: Create class description
public class CircularProgress: SKNode {
    
    // MARK: UI Properties
    
    public var isAnimating: Bool {
        return action(forKey: animationKey) != nil
    }
    
    public var circleRadius: CGFloat = 50 {
        didSet {
            //TODO: Redraw everyone?
        }
    }
    
    public var circleColor: UIColor = .yellow {
        didSet {
            displayedCircle?.strokeColor = circleColor
        }
    }
    
    public var circleLineWidth: CGFloat = 5 {
        didSet {
            if hasDefaultBackground { background?.lineWidth = circleLineWidth }
            displayedCircle?.lineWidth = circleLineWidth
        }
    }
    
    public var lineCap: CGLineCap = .round {
        didSet {
            if hasDefaultBackground { background?.lineCap = lineCap }
            displayedCircle?.lineCap = lineCap
        }
    }
    
    /**
     Background SKShapeNode of the animation.
     The default is a background circle with the same radius and lineWidth of the progress circle.
     
     If no background is needed, just set this to nil.
     */
    public var background: SKShapeNode? {
        willSet {
            guard let currentBackground = background else { return }
            currentBackground.removeFromParent()
        }
        didSet{
            guard let newBackground = background else { return }
            hasDefaultBackground = false
            
            newBackground.zPosition = -1
            addChild(newBackground)
        }
    }
    
    /**
     Label that will be used to show the current `displayStyle`.
     
     **Defaults to nil**.
     */
    public var displayLabel: SKLabelNode? {
        willSet {
            displayLabel?.removeFromParent()
        }
        
        didSet {
            guard let newTextualFeedback = displayLabel else { return }
            
            addChild(newTextualFeedback)
            updatePercentage()
        }
    }
    
    // MARK: Auxiliar Properties
    
    /**
     Flag to help check when updates are made in the Circle properties,
     so if there's a default background, it can be updated as well.
     */
    private var hasDefaultBackground: Bool = true
    
    private var displayedCircle: SKShapeNode?
    private let animationKey = "circularProgressAnimation"
    
    /**
     Should be between 0 and 1 - every other value will be truncated to the next "valid" value.
     
     To update the progress, call `updateProgress(_: duration: completion:)`.
     */
    public private(set) var currentProgress: CGFloat = 0
    
    /// Target progress of the last `updateProgress(_: duration: completion:)`.
    private var targetProgress: CGFloat = 0
    
    /// Target duration of the last `updateProgress(_: duration: completion:)`.
    private(set) var targetDuration: TimeInterval = 0
    
    /// When finishing the `updateProgress(_: duration: completion:)` animation, this completion should be called.
    private var targetCompletion: Completion?
    
    /// Remaining duration when updating the progress (from `duration` to 0)
    public var remainingDuration: TimeInterval {
        let remainingDuration = targetDuration - elapsedTime
        return remainingDuration > 0 ? remainingDuration : 0
    }
    
    /// Elapsed time since the `updateProgress(_:, duration:, completion:)` call
    public var elapsedTime: TimeInterval = 0
    
    /// Direction of the orientation when animating
    public var clockwise: Bool = true
    
    private let startAngle: CGFloat = CGFloat.pi / 2
    private let fullRevolution: CGFloat = 2 * CGFloat.pi
    
    /**
     - Parameters:
     - radius: Radius of the CircularProgress.
     - width: Width of the circle line.
     - color: Color of the circle line.
     - clockwise: If the animation should start counter-clockwise or clockwise.
     */
    public init(withRadius radius: CGFloat,
                width: CGFloat,
                color: UIColor,
                clockwise: Bool) {
        self.circleRadius = radius
        self.circleLineWidth = width
        self.circleColor = color
        self.clockwise = clockwise
        
        super.init()
        
        addDefaultBackground()
        addDefaultDisplayLabel()
    }
    
    public init(withBuilder builder: CircularProgressBuilder?) {
        if let circleColor = builder?.circleColor {
            self.circleColor = circleColor
        }
        
        if let circleRadius = builder?.circleRadius {
            self.circleRadius = circleRadius
        }
        
        if let circleLineWidth = builder?.circleLineWidth {
            self.circleLineWidth = circleLineWidth
        }
        
        if let lineCap = builder?.lineCap {
            self.lineCap = lineCap
        }
        
        if let clockwise = builder?.clockwise {
            self.clockwise = clockwise
        }
        
        super.init()
        
        if let background = builder?.background {
            self.background = background
            addChild(background)
            hasDefaultBackground = false
        } else {
            addDefaultBackground()
        }
        
        if let displayLabel = builder?.displayLabel {
            self.displayLabel = displayLabel
            addChild(displayLabel)
            updatePercentage()
        } else {
            addDefaultDisplayLabel()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addDefaultDisplayLabel() {
        let displayLabel = SKLabelNode()
        displayLabel.verticalAlignmentMode = .center
        displayLabel.horizontalAlignmentMode = .center
        
        self.displayLabel = displayLabel
    }
    
    private func addDefaultBackground() {
        let background = circleNode(withStartAngle: startAngle, endAngle: startAngle + fullRevolution)
        background.lineWidth = circleLineWidth * 0.9
        background.strokeColor = .lightGray
        background.zPosition = -1
        
        self.background = background
    }
    
    // MARK: Public Functions
    
    /**
     Changes the progress based on the current progress.
     This means if `newProgress > currentProgress` the revolution orientation will be clockwise,
     otherwise will be counterclockwise.
     
     - Parameters:
     - newProgress: New value of the circular progress. Should be between 0 and 1.
     - duration: Animation duration. Set to 0 if no animation is necessary. **Defaults to 1**.
     */
    public func updateProgress(_ newProgress: CGFloat, duration: TimeInterval = 1, completion: (() -> Void)? = nil) {
        let verifiedNewProgress = validateProgress(newProgress)
        
        targetDuration = duration
        targetProgress = newProgress
        targetCompletion = completion
        
        //These units are how many "circles" can be drawn in a full revolution.
        //More units means more SKActions (CPU-heavy) but the animation will be more fluid.
        let progressUnits = 1000
        var currentProgressUnits = Int(CGFloat(progressUnits) * currentProgress)
        
        //Find the diff between the newProgress and the currentOne
        let progressDiff = (verifiedNewProgress - currentProgress).rounded(toPlaces: 3)
        let progressDiffUnits = Int(progressDiff * CGFloat(progressUnits))
        if progressDiffUnits == 0 {
            completion?()
            return
        }
        
        //The new progress target in progressUnits
        let targetUnits = currentProgressUnits + progressDiffUnits
        
        //How much time does every animation will need (as it'll be put inside a sequence)
        let animationTimespan = remainingDuration / Double(abs(progressDiffUnits))
        
        let wait = SKAction.wait(forDuration: animationTimespan)
        var fadesActions = [SKAction]()
        
        let isDecreasing = progressDiff < 0
        let orientationModifier = isDecreasing ? -1 : 1
        
        let circleUnit = fullRevolution / CGFloat(progressUnits)
        
        while currentProgressUnits != targetUnits {
            //Building Current Circle
            var showNewCircle: SKAction
            if currentProgressUnits < (progressUnits + (isDecreasing ? 1 : -1)) && currentProgressUnits > 0 {
                showNewCircle = SKAction.run { [unowned self] in
                    self.returnShapeToPool(self.displayedCircle!)
                }
            } else {
                showNewCircle = SKAction.run { }
            }
            
            //Building Next Circle
            let nextIndex = currentProgressUnits + orientationModifier
            
            var hideCurrentCircle: SKAction
            if nextIndex < progressUnits && nextIndex > 0 {
                hideCurrentCircle = SKAction.run { [unowned self] in
                    let endAngleChange = CGFloat(nextIndex) * circleUnit
                    
                    let nextCircle = self.circleNode(withStartAngle: self.startAngle,
                                                     endAngle: self.startAngle + endAngleChange)
                    nextCircle.strokeColor = self.circleColor
                    self.displayedCircle = nextCircle
                    self.addChild(nextCircle)
                }
            } else {
                hideCurrentCircle = SKAction.run { }
            }
            
            let updateProgress = SKAction.run { [unowned self] in
                let progressStep = CGFloat(orientationModifier) / CGFloat(progressUnits)
                self.update(progress: progressStep, duration: animationTimespan)
            }
            
            //Sequencing iteration respective actions
            let animationSwapSequence = SKAction.sequence([showNewCircle, hideCurrentCircle, updateProgress, wait])
            fadesActions.append(animationSwapSequence)
            currentProgressUnits += orientationModifier
        }
        
        run(SKAction.sequence(fadesActions), withKey: animationKey) { [unowned self] in
            self.elapsedTime = 0
            completion?()
        }
    }
    
    private var durationShouldUpdateProgress: Bool = false
    private var changedDuration: TimeInterval?
    
    public func updateDuration(_ duration: TimeInterval, updatingProgress: Bool = true) {
        durationShouldUpdateProgress = updatingProgress
        changedDuration = duration
    }
    
    private func update(duration: TimeInterval) {
        changedDuration = nil
        removeAllActions()
        
        let oldDuration = targetDuration
        let newDuration = oldDuration + duration
        
        if durationShouldUpdateProgress && remainingDuration > 0 {
            let newProgressRatio = oldDuration / newDuration
            let newProgress = targetProgress > currentProgress ?
                currentProgress * CGFloat(newProgressRatio) :
                currentProgress / CGFloat(newProgressRatio)
            currentProgress = newProgress > 1 ? 1 : newProgress
        }
        
        updateProgress(targetProgress, duration: newDuration, completion: targetCompletion)
    }
    
    /**
     Resets the progress (visibly and logically).
     
     When the property `isAnimating == true`, the reset will stop the current ongoing animation.
     - Parameters:
     - completed: If the desired reset state is completed or not. **Defaults to false**.
     */
    public func reset(completed: Bool = false) {
        removeAllActions()
        displayedCircle?.removeFromParent()
        
        currentProgress = completed ? 1 : 0
        
        if completed {
            let completedCircle = circleNode(withStartAngle: startAngle, endAngle: startAngle + fullRevolution)
            completedCircle.strokeColor = circleColor
            
            addChild(completedCircle)
            
            displayedCircle = completedCircle
        } else {
            displayedCircle = nil
        }
        
        updatePercentage()
    }
    
    // MARK: Auxiliar Functions
    
    private func update(progress: CGFloat, duration: TimeInterval) {
        currentProgress += progress
        elapsedTime += duration
        updatePercentage()
        
        if let changedDuration = changedDuration {
            update(duration: changedDuration)
        }
    }
    
    private func validateProgress(_ progress: CGFloat) -> CGFloat {
        switch progress {
        case let value where value < 0: return 0
        case let value where value > 1: return 1
        default: return progress.rounded(toPlaces: 3)
        }
    }
    
    private func circleNode(withStartAngle startAngle: CGFloat, endAngle: CGFloat) -> SKShapeNode {
        let node = pooledShapeNode
        
        //This is actually counter-clockwise, but SpriteKit treats it "inverted"
        let nodePath = UIBezierPath(arcCenter: CGPoint.zero,
                                    radius: circleRadius - circleLineWidth,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
        node.xScale = clockwise ? -1 : 1
        node.path = nodePath.cgPath
        node.lineWidth = circleLineWidth
        node.lineCap = lineCap
        
        return node
    }
    
    private func updatePercentage() {
        let printableProgress = String(format: "%.2f", currentProgress * 100)
        displayLabel?.text = "\(printableProgress)%"
    }
    
    // MARK: SKShapeNode Pooling
    
    private var shapePool = NSMutableArray()
    
    private var pooledShapeNode: SKShapeNode {
        if shapePool.count > 0 {
            let shape = shapePool[0]
            shapePool.remove(shape)
            
            return shape as! SKShapeNode
        }
        
        if shapePool.count > 3 { fatalError("Pool shouldn't be greater than 3: background node and two SKShapeNode being swapped.")}
        
        return SKShapeNode()
    }
    
    private func returnShapeToPool(_ node: SKShapeNode) {
        shapePool.add(node)
        
        node.path = nil
        node.removeFromParent()
    }
}
