//
//  NavigableTextView.swift
//  Mooch
//
//  Created by adam on 9/21/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//TextView that can be used to jump to the next field when pressing return on the keyboard
class NavigableTextView: UITextView {

    weak var nextNavigableTextView: NavigableTextView?
}
