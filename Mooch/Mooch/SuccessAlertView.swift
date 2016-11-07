//
//  SuccessAlertView.swift
//  Mooch
//
//  Created by adam on 11/7/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class SuccessAlertView: UIView {
    
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var informationLabel: UILabel!
    @IBOutlet private weak var successButton: UIButton!
    
    @IBOutlet weak var alertViewCenterYConstraint: NSLayoutConstraint!
    
    private var onAcceptAction: (()->())!
    
    var tap: UITapGestureRecognizer!
    
    @IBAction func onAccept() {
        onAcceptAction()
        
        //Don't retain the closure after it's executed
        onAcceptAction = nil
    }
    
    func onTap() {
        onAcceptAction()
        
        //Don't retain the closure after it's executed
        onAcceptAction = nil
    }
    
    func setup(withInformationText informationText: String, andOnAcceptAction acceptAction: @escaping () -> () ) {
        informationLabel.text = informationText
        onAcceptAction = acceptAction
    }
    
    func animateAlertOnScreen() {
        
        view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.alertViewCenterYConstraint.constant = 0
                
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("SuccessAlertView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("SuccessAlertView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = frame
        
        initialSetup()
    }
    
    private func initialSetup() {
        let checkmark = #imageLiteral(resourceName: "checkmark").imageWithColor(color: ThemeColors.moochYellow.color())
        successButton.setImage(checkmark, for: .normal)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(tap)
    }
}
