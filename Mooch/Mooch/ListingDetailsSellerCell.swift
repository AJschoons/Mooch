//
//  ListingDetailsSellerCell.swift
//  Mooch
//
//  Created by adam on 10/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingDetailsSellerCellDelegate: class {
    func onEmail()
    func onPhone()
}

class ListingDetailsSellerCell: UITableViewCell {
    
    static let Identifier = "ListingDetailsSellerCell"
    static let EstimatedHeight: CGFloat = 203
    
    @IBOutlet weak var sellerImageView: CircleImageView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    weak var delegate: ListingDetailsSellerCellDelegate!
    
    @IBOutlet private weak var sellerContactInformation: UIStackView!
    @IBOutlet private weak var hiddenContactInformationView: UIView!
    
    @IBOutlet private weak var emailImageView: UIImageView!
    @IBOutlet private weak var phoneImageView: UIImageView!
    @IBOutlet private weak var addressImageView: UIImageView!
    
    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet private weak var phoneButton: UIButton!
    @IBOutlet private weak var addressButton: UIButton!
    
    private var showSellerInfo = false
    
    @IBAction func onEmailButton() {
        guard showSellerInfo else { return }
        delegate.onEmail()
    }
    
    @IBAction func onPhoneButton() {
        guard showSellerInfo else { return }
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
    
    func setButtonStateAndText(from listing: Listing) {
        if let showInfo = listing.isUserAllowedToSeeOwnerContactInformation {
            showSellerInfo = showInfo
        }
        
        //An informational view will be shown instead to show how to get seller information
        guard showSellerInfo else {
            sellerContactInformation.isHidden = true
            return
        }
        
        hiddenContactInformationView.isHidden = true
        
        emailButton.setTitle(listing.owner.contactInformation.email, for: .normal)
        
        if let phone = listing.owner.contactInformation.phone {
            let formattedPhone = PhoneNumberHandler.format(number: phone)
            phoneButton.setTitle(formattedPhone, for: .normal)
            phoneButton.isUserInteractionEnabled = true
        } else {
            phoneButton.setTitle("No phone provided", for: .normal)
            phoneButton.isUserInteractionEnabled = true
        }
        
        
        //Nothing to do with the address button, so always disabled
        addressButton.isUserInteractionEnabled = false
        if let address = listing.owner.contactInformation.address {
            addressButton.setTitle(address, for: .normal)
        } else {
            addressButton.setTitle("No address provided", for: .normal)
        }
    }
}
