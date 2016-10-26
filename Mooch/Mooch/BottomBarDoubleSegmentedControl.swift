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
    
    @IBOutlet private var firstControlView: UIView!
    @IBOutlet private var firstControlButton: UIButton!
    @IBOutlet private var firstControlBottomBar: UIView!
    
    @IBOutlet private var secondControlView: UIView!
    @IBOutlet private var secondControlButton: UIButton!
    @IBOutlet private var secondControlBottomBar: UIView!
    
    private(set) var selectedControl: Control = .first
    
    private var textColor: UIColor = .black
    private var controlBackgroundColor: UIColor = .clear
    private var fontSize: CGFloat = 12
    
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
        updateUI()
        delegate?.didSelect(.first)
    }
    
    @IBAction func onSecondControl() {
        selectedControl = .second
        updateUI()
        delegate?.didSelect(.second)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("BottomBarDoubleSegmentedControl", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        updateUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("BottomBarDoubleSegmentedControl", owner: self, options: nil)
        self.addSubview(view)
        view.frame = frame
        
        updateUI()
    }
    
    func updateUI() {
        view.backgroundColor = .clear
        
        let isFirstControlSelected = (selectedControl == .first)
        
        let selectedControlButton: UIButton = isFirstControlSelected ? firstControlButton : secondControlButton
        let unselectedControlButton: UIButton = isFirstControlSelected ? secondControlButton : firstControlButton
        selectedControlButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        selectedControlButton.setTitleColor(textColor, for: .normal)
        unselectedControlButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        unselectedControlButton.setTitleColor(textColor, for: .normal)
        
        let selectedControlBottomBar: UIView = isFirstControlSelected ? firstControlBottomBar : secondControlBottomBar
        let unselectedControlBottomBar: UIView = isFirstControlSelected ? secondControlBottomBar : firstControlBottomBar
        selectedControlBottomBar.backgroundColor = textColor
        selectedControlBottomBar.isHidden = false
        unselectedControlBottomBar.backgroundColor = textColor
        unselectedControlBottomBar.isHidden = true
        
        firstControlView.backgroundColor = controlBackgroundColor
        secondControlView.backgroundColor = controlBackgroundColor
    }
}
