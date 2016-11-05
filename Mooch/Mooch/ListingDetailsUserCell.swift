//
//  ListingDetailsSellerCell.swift
//  Mooch
//
//  Created by adam on 10/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsUserCellDelegate: class {
    func onEmail()
    func onPhone()
}

class ListingDetailsUserCell: UITableViewCell {
    
    enum UserType {
        case seller
        case buyer
    }
    
    static let Identifier = "ListingDetailsUserCell"
    static let EstimatedHeight: CGFloat = 208
    
    @IBOutlet weak var userImageView: CircleImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet private weak var headingLabel: UILabel!
    
    @IBOutlet private weak var userContactInformation: UIStackView!
    @IBOutlet private weak var hiddenContactInformationView: UIView!
    
    @IBOutlet private weak var emailImageView: UIImageView!
    @IBOutlet private weak var phoneImageView: UIImageView!
    @IBOutlet private weak var addressImageView: UIImageView!
    
    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet private weak var phoneButton: UIButton!
    @IBOutlet private weak var addressButton: UIButton!
    
    weak var delegate: ListingDetailsUserCellDelegate!
    private var showUserInfo = false
    
    @IBAction func onEmailButton() {
        guard showUserInfo else { return }
        delegate.onEmail()
    }
    
    @IBAction func onPhoneButton() {
        guard showUserInfo else { return }
        delegate.onPhone()
    }
    
    func setIconsAndButtons(with color: UIColor) {
        emailImageView.image = UIImage(named: "email")?.imageWithColor(color: color)
        phoneImageView.image = UIImage(named: "phone")?.imageWithColor(color: color)
        addressImageView.image = UIImage(named: "home")?.imageWithColor(color: color)
        
        emailButton.setTitleColor(color, for: .normal)
        phoneButton.setTitleColor(color, for: .normal)
        addressButton.setTitleColor(color, for: .normal)
    }
    
    func setup(with user: User, andType userType: UserType, isUserContactInformationVisible: Bool) {
        switch userType {
        case .buyer:
            headingLabel.text = "About Buyer"
        case .seller:
            headingLabel.text = "About Seller"
        }
        
        showUserInfo = isUserContactInformationVisible
        
        //An informational view will be shown instead to show how to get seller information
        guard showUserInfo else {
            userContactInformation.isHidden = true
            return
        }
        
        hiddenContactInformationView.isHidden = true
        
        emailButton.setTitle(user.contactInformation.email, for: .normal)
        
        if let phone = user.contactInformation.phone {
            let formattedPhone = PhoneNumberHandler.format(number: phone)
            phoneButton.setTitle(formattedPhone, for: .normal)
            phoneButton.isUserInteractionEnabled = true
        } else {
            phoneButton.setTitle("No phone provided", for: .normal)
            phoneButton.isUserInteractionEnabled = true
        }
        
        
        //Nothing to do with the address button, so always disabled
        addressButton.isUserInteractionEnabled = false
        if let address = user.contactInformation.address {
            addressButton.setTitle(address, for: .normal)
        } else {
            addressButton.setTitle("No address provided", for: .normal)
        }
    }
}
