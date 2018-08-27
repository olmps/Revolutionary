//
//  CircularProgress.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

//TODO: Create class description
public class CircularProgress: SKNode {
    
    /// A Central display style to see the current state of the CircularProgress.
    public enum DisplayStyle {
        /// Nothing will be displayed
        case none
        
        /**
         The display will be formatted relative to the remaining time
         and will probably the most simple scenario.
         
         ## Examples:
         - 80 remaining seconds will output 80;
         - 3666 remaining seconds will output 3666.
         */
        case simpleRemainingTime
        
        /**
         The display will be formatted relative to the remaining time
         with a more compacted style.
         
         ## Examples:
         - 80 remaining seconds will output 01:20;
         - 3666 remaining seconds will output 01:01:06.
         */
        case compactedRemainingTime
        
        /**
         The display will be formatted relative to the remaining time
         with a full description.
         
         ## Examples:
            - 80 remaining seconds will output 00:01:15;
            - 3666 remaining seconds will output 01:01:06.
         */
        case fullRemainingTime
        
        /**
         The current progress percentage.
         */
        case percentage
    }
    
    // MARK: UI Properties
    
    public var isAnimating: Bool {
        return action(forKey: animationKey) != nil
    }
    
    public let circleRadius: CGFloat
    
    public var circleColor: UIColor {
        didSet {
            displayedCircle?.strokeColor = circleColor
        }
    }
    
    public var circleLineWidth: CGFloat {
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
    
    /// Node that follows the tip of the circular progress.
    public var circleTip: SKShapeNode? {
        willSet {
            guard let currentCircleTip = circleTip else { return }
            currentCircleTip.removeFromParent()
        }
        didSet{
            guard let newCircleTip = circleTip else { return }
            addChild(newCircleTip)
            
            updateCircleTip()
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
     Display style of the current progress state.
     
     **Defaults to `.none`**.
     */
    public var displayStyle: DisplayStyle = .none {
        didSet {
            if displayStyle != .none && displayLabel == nil {
                displayLabel = SKLabelNode()
                displayLabel?.verticalAlignmentMode = .center
                displayLabel?.horizontalAlignmentMode = .center
            }
        }
    }
    
    /**
     Label that will be used to show the current `displayStyle`.
     
     **Defaults to nil**.
     */
    public var displayLabel: SKLabelNode? {
        willSet {
            guard let currentTextualFeedback = displayLabel else { return }
            currentTextualFeedback.removeFromParent()
        }
        didSet {
            guard let newTextualFeedback = displayLabel else { return }
            
            addChild(newTextualFeedback)
            updateDisplay()
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

    //TODO: Find the ratio between circleRadius and this value to make the animation seems fluid.
    //Also describe the currentProgress + progressInCircles better.
    //BTW: NumberOfCircles isn't needed, this could be just some "auxiliar variable" inside the updateProgress function.
    private let numberOfCircles = 1000
    
    /**
     Should be between 0 and 1 - every other value will be truncated to the next "valid" value.
     
     To update the progress, call `updateProgress(_: duration: completion:)`.
     */
    public private(set) var currentProgress: CGFloat = 0
    
    private var progressInCircles = 0
    private var remainingDuration: TimeInterval = 0
    /**
     - Parameters:
         - radius: Radius of the CircularProgress.
         - width: Width of the circle line.
         - color: Color of the circle line.
     */
    required public init(withRadius radius: CGFloat,
                         width: CGFloat,
                         color: UIColor) {
        self.circleRadius = radius
        self.circleLineWidth = width
        self.circleColor = color
        super.init()
        
        //Default Background
        let background = circleNode(withStartAngle: 0, endAngle: 2 * CGFloat.pi)
        background.strokeColor = .lightGray
        background.zPosition = -1
        
        addChild(background)
        
        self.background = background
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        remainingDuration = duration
        
        //Find the diff between the newProgress and the currentOne
        let progressDiff = (verifiedNewProgress - currentProgress).rounded(toPlaces: 3)
        let progressDiffUnits = Int(progressDiff * CGFloat(numberOfCircles))
        if progressDiffUnits == 0 { return }
        
        //new "amount" of circles displayed
        let newCirclesAmount = progressInCircles + progressDiffUnits
        
        //How much time does every animation will need (as it'll be put inside a sequence)
        let animationTimespan = duration / Double(abs(progressDiffUnits))
        
        let wait = SKAction.wait(forDuration: animationTimespan)
        var fadesActions = [SKAction]()
        
        //Reversed means that the the progress is going "backwards"
        let reversed = progressDiff < 0
        let orientationModifier = reversed ? -1 : 1
        
        let initialAngle = CGFloat.pi / 2
        let circleUnit = (2 * CGFloat.pi) / CGFloat(numberOfCircles)
        
        while progressInCircles != newCirclesAmount {
            //Building Current Circle
            var showNewCircle: SKAction
            if progressInCircles < (numberOfCircles + (reversed ? +1 : -1)) && progressInCircles > 0 {
                showNewCircle = SKAction.run {
                    self.returnShapeToPool(self.displayedCircle!)
                }
            } else {
                showNewCircle = SKAction.run { }
            }
            
            //Building Next Circle
            let nextIndex = progressInCircles + orientationModifier
            
            var hideCurrentCircle: SKAction
            if nextIndex < numberOfCircles && nextIndex > 0 {
                hideCurrentCircle = SKAction.run {
                    let nextCircle = self.circleNode(withStartAngle: initialAngle,
                                                     endAngle: initialAngle - (CGFloat(nextIndex) * circleUnit))
                    nextCircle.strokeColor = self.circleColor
                    self.displayedCircle = nextCircle
                    self.addChild(nextCircle)
                }
            } else {
                hideCurrentCircle = SKAction.run { }
            }
            
            let updateProgress = SKAction.run {
                let progressStep = CGFloat(orientationModifier) / CGFloat(self.numberOfCircles)
                self.update(progress: progressStep, duration: animationTimespan)
            }
            
            //Sequencing iteration respective actions
            let animationSwapSequence = SKAction.sequence([showNewCircle, hideCurrentCircle, updateProgress, wait])
            fadesActions.append(animationSwapSequence)
            progressInCircles += orientationModifier
        }
        
        run(SKAction.sequence(fadesActions), withKey: animationKey) {
            completion?()
        }
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
        progressInCircles = completed ? numberOfCircles : 0
        
        if completed {
            let completedCircle = circleNode(withStartAngle: 0, endAngle: 2 * CGFloat.pi)
            completedCircle.strokeColor = circleColor
            
            addChild(completedCircle)
            
            displayedCircle = completedCircle
        } else {
            displayedCircle = nil
        }
        
        updateCircleTip()
        updateDisplay()
    }
    
    // MARK: Auxiliar Functions
    
    private func update(progress: CGFloat, duration: TimeInterval) {
        currentProgress += progress
        remainingDuration -= duration
        updateCircleTip()
        updateDisplay()
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
        let nodePath = UIBezierPath.init(arcCenter: CGPoint.zero,
                                         radius: circleRadius,
                                         startAngle: startAngle,
                                         endAngle: endAngle,
                                         clockwise: false)
        node.path = nodePath.cgPath
        node.lineWidth = circleLineWidth
        node.lineCap = lineCap
        
        return node
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

// MARK: UI Auxiliar Functions

extension CircularProgress {
    //TODO: CircleTip
    private func updateCircleTip() {
        guard let availableCircleTip = circleTip else { return }
        
        //Logic to place the circle tip at the end of the last visible circle
    }
    
    private func updateDisplay() {
        guard let availableDisplay = displayLabel else { return }
        let duration = Int(remainingDuration) + 1
        
        switch displayStyle {
        case .percentage:
            let printableProgress = String(format: "%.2f", currentProgress * 100)
            availableDisplay.text = "\(printableProgress)%"
            
        case .simpleRemainingTime:
            availableDisplay.text = "\(duration)"
            
        case .compactedRemainingTime:
            let hours = duration / 3600
            let hoursAvailable = hours > 0
            let minutes = (duration / 60) % 60
            let minutesAvailable = minutes > 0
            let seconds = duration % 60
            
            if hoursAvailable {
                availableDisplay.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
            } else if minutesAvailable {
                availableDisplay.text = String(format: "%02i:%02i", minutes, seconds)
            } else {
                availableDisplay.text = String(format: "%02i", seconds)
            }
            
        case .fullRemainingTime:
            let hours = duration / 3600
            let minutes = (duration / 60) % 60
            let seconds = duration % 60
            availableDisplay.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
            
        default: break
        }
    }
}
