//
//  EditProfileTextField.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

class EditProfileTextField: UITextField, NavigableResponder {
    
    weak var nextNavigableResponder: UIResponder?
    
    var fieldType: EditProfileConfiguration.FieldType!
}
