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
            defaultBackground?.lineWidth = circleLineWidth
            customBackground?.lineWidth = circleLineWidth
            displayedCircle?.lineWidth = circleLineWidth
        }
    }
    
    public var lineCap: CGLineCap = .round {
        didSet {
            defaultBackground?.lineCap = lineCap
            customBackground?.lineCap = lineCap
            displayedCircle?.lineCap = lineCap
        }
    }
    
    /// Node that follows the tip of the circular progress.
    public var circleTip: SKShapeNode? {
        willSet {
            guard let currentCircleTip = circleTip, newValue == nil else { return }
            currentCircleTip.removeFromParent()
        }
        didSet{
            guard let newCircleTip = circleTip else { return }
            addChild(newCircleTip)
            
            positionCircleTip()
        }
    }
    
    /// Overrides the `CircularProgress.defaultBackground` property.
    public var customBackground: SKShapeNode? {
        willSet {
            guard let currentBackground = customBackground, newValue == nil else { return }
            currentBackground.removeFromParent()
        }
        didSet{
            guard let newBackground = customBackground else { return }
            
            defaultBackground?.removeFromParent()
            defaultBackground = nil
            
            addChild(newBackground)
        }
    }
    
    /// Color of the background node. Affects both custom and default backgrounds.
    public var backgroundColor: UIColor {
        didSet {
            customBackground?.strokeColor = backgroundColor
            defaultBackground?.strokeColor = backgroundColor
        }
    }
    
    private var defaultBackground: SKShapeNode?
    
    // MARK: Auxiliar Properties
    
    private var displayedCircle: SKShapeNode?
    private let animationKey = "circularProgressAnimation"
    
    //TODO: Find the ratio between circleRadius and this value to make the animation seems fluid.
    //Also describe the currentProgress + progressInCircles better.
    private let numberOfCircles = 1000
    
    //FIXME: currentProgress isn't correctly being updated with the UI
    public private(set) var currentProgress: CGFloat = 0
    private var progressInCircles = 0
    
    /**
     - Parameters:
         - radius: Radius of the CircularProgress.
         - width: Width of the circle line.
         - color: Color of the circle line.
         - hasBackground: If the circle should display a background.
         - progress: Should be between 0 and 1 - every other value will be truncated to the next "valid" value. **Defaults to 0**.
     */
    required public init(withRadius radius: CGFloat,
                  width: CGFloat,
                  color: UIColor,
                  hasBackground: Bool = true,
                  progress: CGFloat = 0) {
        self.circleRadius = radius
        self.circleLineWidth = width
        self.circleColor = color
        self.backgroundColor = .lightGray
        
        super.init()
        
        self.currentProgress = validateProgress(progress)
        self.progressInCircles = Int(currentProgress * CGFloat(numberOfCircles))
        
        if hasBackground {
            defaultBackground = circleNode(withStartAngle: 0, endAngle: 2 * CGFloat.pi)
            setupBackground()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Functions
    
    /**
     Changes the current progress based on the `clockwise` orientation of the revolution.
     
     - Parameters:
        - newProgress: New value of the circular progress. Should be between 0 and 1.
        - duration: Animation duration. Set to 0 if no animation is necessary. **Defaults to 1**.
     */
    public func updateProgress(_ newProgress: CGFloat, duration: TimeInterval = 1, completion: (() -> Void)? = nil) {
        let verifiedNewProgress = validateProgress(newProgress)
        
        //Find the diff between the newProgress and the currentOne
        let progressDiff = (verifiedNewProgress - currentProgress).rounded(toPlaces: 3)
        let progressDiffUnits = Int(progressDiff * CGFloat(numberOfCircles))
        if progressDiffUnits == 0 { return }
        
        let newCirclesAmount = progressInCircles + progressDiffUnits //new "amount" of circles displayed
        
        //How much time does every animation will need (as it'll be put inside a sequence)
        let animationTimespan = duration / Double(abs(progressDiffUnits))
        
        let wait = SKAction.wait(forDuration: animationTimespan)
        var fadesActions = [SKAction]()
        
        //Reversed means that the the progress is going "backwards"
        let reversed = progressDiff < 0
        
        let initialAngle = CGFloat.pi / 2
        let circleUnit = (2 * CGFloat.pi) / CGFloat(numberOfCircles)
        
        while progressInCircles != newCirclesAmount {
            let orientationModifier = reversed ? -1 : 1
            
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
            
            //Sequencing iteration respective actions
            fadesActions.append(SKAction.sequence([showNewCircle, hideCurrentCircle, wait]))
            progressInCircles += orientationModifier
        }
        
        currentProgress = verifiedNewProgress
        
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
        removeAllChildren()
        removeAllActions()
        
        currentProgress = completed ? 1 : 0
        progressInCircles = completed ? numberOfCircles : 0
        
        if defaultBackground != nil || customBackground != nil {
            setupBackground()
        }
        
        if completed {
            let completedCircle = circleNode(withStartAngle: 0, endAngle: 2 * CGFloat.pi)
            completedCircle.strokeColor = circleColor
            
            displayedCircle = completedCircle
        } else {
            displayedCircle = nil
        }
    }
    
    // MARK: Auxiliar Functions
    
    //TODO: CircleTip
    private func positionCircleTip() {
        guard let availableCircleTip = circleTip else { return }
        
        //Logic to place the circle tip at the end of the last visible circle
    }
    
    //FIXME: Background approach
    private func setupBackground() {
        var background: SKShapeNode
        
        if let customBackground = customBackground {
            background = customBackground
        } else {
            background = circleNode(withStartAngle: 0, endAngle: 2 * CGFloat.pi)
        }
        
        background.strokeColor = backgroundColor
        background.zPosition = -1
        
        addChild(background)
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
