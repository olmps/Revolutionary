//
//  RevolutionaryView.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 15/02/19.
//  Copyright © 2019 gmatuella. All rights reserved.
//

import SpriteKit

/**
 Wrapper to quickly instantiate a `RevolutionaryScene` with a `Revolutionary` and put it inside UIKit.
 
 The proposed solution is to directly call the `RevolutionaryView.rev` property, otherwise all functions and comments would need to be replicated.
 */
public class RevolutionaryView: SKView {
    
    private var revScene: RevolutionaryScene!
    
    /// Acessor to the Revolutionary SKNode
    public var rev: Revolutionary {
        return revScene.rev
    }
    //TODO: ADD DESC
    public init(_ builder: RevolutionaryBuilder, frame: CGRect, padding: CGFloat = 16) {
        self.revScene = RevolutionaryScene(builder, size: frame.size, padding: padding)
        super.init(frame: frame)
        commonInit()
    }
    
    //TODO: ADD DESC
    public init(frame: CGRect, padding: CGFloat = 16) {
        self.revScene = RevolutionaryScene(size: frame.size, padding: padding)
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        allowsTransparency = true
        presentScene(revScene)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/**
 Wrapper to quickly instantiate a `Revolutionary`.
 
 The proposed solution is to directly call the `RevolutionaryScene.rev` property, otherwise all functions and comments would need to be replicated.
 */
public class RevolutionaryScene: SKScene {

    /// Acessor to the Revolutionary SKNode
    public let rev: Revolutionary
    
    //TODO: ADD DESC
    public init(_ builder: RevolutionaryBuilder, size: CGSize, padding: CGFloat = 16) {
        let arcRadius = (size.height / 2) - padding
        self.rev = Revolutionary(withRadius: arcRadius, builder: builder)
        super.init(size: size)
        
        commonInit()
    }
    
    //TODO: ADD DESC
    public init(size: CGSize, padding: CGFloat = 16) {
        let arcRadius = (size.height / 2) - padding
        self.rev = Revolutionary(withRadius: arcRadius)
        super.init(size: size)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        rev.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(rev)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
