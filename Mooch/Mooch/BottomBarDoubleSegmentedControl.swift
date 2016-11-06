//
//  BottomBarDoubleSegmentedControl.swift
//  Mooch
//
//  Created by adam on 10/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol BottomBarDoubleSegmentedControlDelegate: class {
    
    func didSelect(_ selectedControl: BottomBarDoubleSegmentedControl.Control)
}

class BottomBarDoubleSegmentedControl: UIView {
    
    enum Control: Int {
        case first = 0
        case second = 1
    }
    
    weak var delegate: BottomBarDoubleSegmentedControlDelegate?
    
    @IBOutlet private var view: UIView!
    
    private var bottomBar: UIView!
    
    @IBOutlet private var firstControlView: UIView!
    @IBOutlet private var firstControlButton: UIButton!
    
    @IBOutlet private var secondControlView: UIView!
    @IBOutlet private var secondControlButton: UIButton!
    
    private(set) var selectedControl: Control = .first
    
    private var textColor: UIColor = ThemeColors.moochRed.color()
    private var controlBackgroundColor: UIColor = .clear
    private var fontSize: CGFloat = 13
    
    private let HeightForBottomBar: CGFloat = 3
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomBar.frame = frameForBottomBar()
    }
    
    func set(title: String, for control: Control) {
        switch control {
        case .first:
            firstControlButton.setTitle(title, for: .normal)
            
        case .second:
            secondControlButton.setTitle(title, for: .normal)
        }
    }
    
    @IBAction func onFirstControl() {
        selectedControl = .first
        updateUI(withAnimation: true)
        delegate?.didSelect(.first)
    }
    
    @IBAction func onSecondControl() {
        selectedControl = .second
        updateUI(withAnimation: true)
        delegate?.didSelect(.second)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("BottomBarDoubleSegmentedControl", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("BottomBarDoubleSegmentedControl", owner: self, options: nil)
        self.addSubview(view)
        view.frame = frame
        
        setup()
    }
    
    func update(selectedControl: Control, animated: Bool) {
        self.selectedControl = selectedControl
        updateUI(withAnimation: animated)
    }
    
    private func updateUI(withAnimation shouldAnimate: Bool) {
        view.backgroundColor = .clear
        
        let isFirstControlSelected = (selectedControl == .first)
        
        let selectedControlButton: UIButton = isFirstControlSelected ? firstControlButton : secondControlButton
        let unselectedControlButton: UIButton = isFirstControlSelected ? secondControlButton : firstControlButton
        selectedControlButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        selectedControlButton.setTitleColor(textColor, for: .normal)
        unselectedControlButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        unselectedControlButton.setTitleColor(textColor, for: .normal)
        
        firstControlView.backgroundColor = controlBackgroundColor
        secondControlView.backgroundColor = controlBackgroundColor
        
        bottomBar.backgroundColor = textColor
        
        let newFrameForBottomBar = frameForBottomBar()
        
        if shouldAnimate {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.7,
                options: .curveEaseOut,
                animations: {
                    self.bottomBar.frame = newFrameForBottomBar
                },
                completion: nil
            )
        } else {
            bottomBar.frame = newFrameForBottomBar
        }
    }
    
    private func setup() {
        createBottomBar()
        updateUI(withAnimation: false)
    }
    
    private func createBottomBar() {
        bottomBar = UIView(frame: frameForBottomBar())
        bottomBar.backgroundColor = textColor
        view.addSubview(bottomBar)
    }
    
    private func frameForBottomBar() -> CGRect {
        let y = view.bounds.height - HeightForBottomBar
        let x = selectedControl == .first ? firstControlView.frame.origin.x : secondControlView.frame.origin.x
        let width = view.bounds.width / 2
        return CGRect(x: x, y: y, width: width, height: HeightForBottomBar)
    }
}
