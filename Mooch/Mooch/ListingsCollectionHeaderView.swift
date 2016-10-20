//
//  ListingsCollectionHeaderView.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingsCollectionHeaderViewDelegate: class {
    func onFilterAction()
}

class ListingsCollectionHeaderView: UICollectionReusableView {
    
    static let Identifier = "ListingsCollectionHeaderView"
    
    @IBOutlet private weak var communityNameLabel: UILabel!
    
    weak var delegate: ListingsCollectionHeaderViewDelegate!
    
    @IBAction func onFilterAction() {
        delegate.onFilterAction()
    }
    
    func set(communityName: String) {
        communityNameLabel.text = communityName
    }
}
