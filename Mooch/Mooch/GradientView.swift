//
//  VerticalGradientView.swift
//  Mooch
//
//  Created by adam on 10/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateGradientColors()
        }
    }
    
    
    @IBInspectable var secondColor: UIColor = UIColor.black {
        didSet {
            updateGradientColors()
        }
    }
    
    private var gradientLayer: CAGradientLayer!
    
    func updateGradientColors() {
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
    }
    
    override open class var layerClass: AnyClass {
        get{
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gradientLayer = self.layer as! CAGradientLayer
        updateGradientColors()
    }
}
