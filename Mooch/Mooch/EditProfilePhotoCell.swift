//
//  EditProfilePhotoCell.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditProfilePhotoCell: UITableViewCell, EditProfileField {
    
    static let Identifier = "EditProfilePhotoCell"
    static let EstimatedHeight: CGFloat = 366
    
    @IBOutlet weak var photoAddingView: PhotoAddingView!
    
    var fieldType: EditProfileConfiguration.FieldType!
}
