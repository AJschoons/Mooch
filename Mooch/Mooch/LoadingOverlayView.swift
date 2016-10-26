//
//  LoadingOverlayView.swift
//  Mooch
//
//  Created by adam on 10/4/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class LoadingOverlayView: UIView {

    @IBOutlet private var view: UIView!
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var informationLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    func update(withProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func setup(withInformationText informationText: String?, isUserInteractionEnabled: Bool, isProgressBased: Bool, isAlertViewHidden: Bool) {
        alertView.isHidden = isAlertViewHidden
        
        if let text = informationText {
            informationLabel.text = text
        } else {
            informationLabel.text = nil
        }
        
        activityIndicator.isHidden = isProgressBased
        progressView.isHidden = !isProgressBased
        
        view.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("LoadingOverlayView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("LoadingOverlayView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = frame
    }
    
    //Allows touches to pass through the overlay. Returning false allows the touch to pass through
    //http://stackoverflow.com/questions/3046813/how-can-i-click-a-button-behind-a-transparent-uiview
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard view.isUserInteractionEnabled else { return true }
        
        return alertView.point(inside: convert(point, to: alertView), with: event)
    }
}
