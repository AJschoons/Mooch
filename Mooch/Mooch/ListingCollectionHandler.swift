//
//  ListingsCollectionHandler.swift
//  Mooch
//
//  Created by adam on 10/16/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//Super class that handles a Listings collection view. Should be subclassed
class ListingCollectionHandler: NSObject {
    
    static let SectionInsets = Theming.InsetsForTileCollectionViewCells
    
    //Subclasses CAN choose to override this to do more things, such as adding a refresh control
    func onDidSet(collectionView: UICollectionView) {
        //Register the cell
        let nib = UINib(nibName: ListingCollectionViewCell.Identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ListingCollectionViewCell.Identifier)
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            onDidSet(collectionView: collectionView)
        }
    }
    
    //Needs to be an integer to work properly
    @IBInspectable var itemsPerRow: CGFloat = 2
}

//Note: for subclasses to use data source methods, the method must be defined here and then overriden in the subclass
extension ListingCollectionHandler: UICollectionViewDataSource {
    
    //Subclasses should override
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    //Subclasses should override
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    //Subclasses CAN override if needed
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}

//Note: for subclasses to use delegate methods, the method must be defined here and then overriden in the subclass
extension ListingCollectionHandler: UICollectionViewDelegate {
    
    //Subclasses have to override to use this
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    //Subclasses CAN override if needed
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
}

extension ListingCollectionHandler: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}
}

extension ListingCollectionHandler: UICollectionViewDelegateFlowLayout {
    
    //Subclasses should NOT override
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = ListingCollectionHandler.SectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //Subclasses should NOT override
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return ListingCollectionHandler.SectionInsets
    }
    
    //Subclasses should NOT override
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ListingCollectionHandler.SectionInsets.left
    }
    
    //Subclasses CAN override if needed
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
}
