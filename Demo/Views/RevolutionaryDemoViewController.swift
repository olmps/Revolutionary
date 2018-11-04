//
//  RevolutionaryDemoViewController.swift
//  Demo
//
//  Created by Guilherme Carlos Matuella on 01/11/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

struct UI {
    static let outsidePadding: CGFloat = 16
    static let innerPadding: CGFloat = 8
}

class RevolutionaryDemoViewController: UIViewController {
    
    // MARK: SKView Contents
    
    let skView: SKView = {
        let skView = SKView()
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        return skView
    }()
    private func setupSKView() {
        view.addSubview(skView)
        
        skView.edgesToSuperview(excluding: .bottom)
        skView.heightToSuperview(multiplier: 0.5)
        
        skView.layoutIfNeeded()
    }
    
    // MARK: ScrollView + StackView Wrapper
    
    let scrollViewWrapper: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.isScrollEnabled = true
        
        return scrollView
    }()
    private func setupScrollView() {
        view.addSubview(scrollViewWrapper)
        
        scrollViewWrapper.edgesToSuperview(excluding: [.top, .bottom])
        scrollViewWrapper.topToBottom(of: skView, offset: UI.outsidePadding)
    }
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = UI.outsidePadding
        
        return stackView
    }()
    private func setupContentStackView() {
        scrollViewWrapper.addSubview(contentStackView)
        contentStackView.widthToSuperview(offset: -UI.outsidePadding * 2)
        contentStackView.centerXToSuperview()
        contentStackView.edgesToSuperview(excluding: [.leading, .trailing])
        contentStackView.leadingToSuperview(offset: UI.outsidePadding)
        contentStackView.trailingToSuperview(offset: UI.outsidePadding)
    }
    
    // MARK: Animate Button
    
    enum AnimationState {
        case animating
        case paused
        case stopped
    }
    var state = AnimationState.stopped
    
    let animateButton: UIButton = {
        let animateButton = UIButton()
        animateButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        animateButton.translatesAutoresizingMaskIntoConstraints = false
        animateButton.setTitle("ANIMATE", for: .normal)
        
        animateButton.setTitleColor(.white, for: .normal)
        animateButton.setBackgroundColor(color: .cyan, forState: .normal)
        
        animateButton.setBackgroundColor(color: .blue, forState: .highlighted)
        
        return animateButton
    }()
    private func setupAnimateButton() {
        view.addSubview(animateButton)
        
        animateButton.height(40)
        animateButton.widthToSuperview(multiplier: 0.5)
        animateButton.centerXToSuperview()
        animateButton.topToBottom(of: scrollViewWrapper, offset: UI.outsidePadding * 2)
        animateButton.bottomToSuperview(offset: -UI.outsidePadding)
    }
    
    // Helper Functions
    
    func addPairToContentStack(firstView: UIView, secondView: UIView) {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        stackView.addArrangedSubview(firstView)
        firstView.leadingToSuperview()
        stackView.addArrangedSubview(secondView)
        secondView.trailingToSuperview()
        
        contentStackView.addArrangedSubview(stackView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
        //        self.extendedLayoutIncludesOpaqueBars = false
        
        view.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
        addDismissTap()
        
        setupSKView()
        setupScrollView()
        setupContentStackView()
        setupAnimateButton()
    }
}
