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
    @IBOutlet weak var alertView: UIView!
    @IBOutlet private weak var informationLabel: UILabel!
    
    func setup(withInformationText informationText: String?, isUserInteractionEnabled: Bool) {
        if let text = informationText {
            informationLabel.text = text
        } else {
            informationLabel.text = nil
        }
        
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
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled else { return true }
        
        return alertView.point(inside: convert(point, to: alertView), with: event)
    }
}
