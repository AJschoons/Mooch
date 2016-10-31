//
//  EditListingPhotoCell.swift
//  Mooch
//
//  Created by adam on 9/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditListingPhotoCell: UITableViewCell, EditListingField {
    
    static let Identifier = "EditListingPhotoCell"
    static let EstimatedHeight: CGFloat = 200
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var fieldType: EditListingConfiguration.FieldType!
}
