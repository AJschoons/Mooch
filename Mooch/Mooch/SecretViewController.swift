//
//  SecretViewController.swift
//  Mooch
//
//  Created by adam on 11/12/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol SecretViewControllerDelegate: class {
    func onSecretAction()
}

class SecretViewController: MoochModalViewController {
    
    static fileprivate let StoryboardName = "Secret"
    static fileprivate let Identifier = "SecretViewController"
    
    @IBOutlet weak var moochLabel: UILabel!
    @IBOutlet weak var secretImage: UIImageView!
    @IBOutlet weak var secretButtonLabel: UILabel!
    @IBOutlet weak var secretButton: UIButton!
    
    var delegate: SecretViewControllerDelegate!
    
    @IBAction func onSecretAction() {
        delegate.onSecretAction()
    }
    
    static func instantiateFromStoryboard() -> SecretViewController {
        let storyboard = UIStoryboard(name: SecretViewController.StoryboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: SecretViewController.Identifier) as! SecretViewController
    }
    
    override func setup() {
        moochLabel.textColor = ThemeColors.moochRed.color()
        secretImage.image = #imageLiteral(resourceName: "westworld").imageWithColor(color: ThemeColors.moochRed.color())
        secretButtonLabel.textColor = ThemeColors.moochYellow.color()
        secretButton.setImage(#imageLiteral(resourceName: "corn").imageWithColor(color: ThemeColors.moochYellow.color()), for: .normal)
    }
}
