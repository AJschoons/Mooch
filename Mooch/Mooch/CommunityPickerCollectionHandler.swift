//
//  CommunityPickerCollectionHandler.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol CommunityPickerCollectionHandlerDelegate: class {
    func getCommunities() -> [Community]
    func didSelect(_ community: Community)
}

class CommunityPickerCollectionHandler: NSObject {
    
    static let SectionInsets = Theming.InsetsForTileCollectionViewCells
    
    weak var delegate: CommunityPickerCollectionHandlerDelegate!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            onDidSet(collectionView: collectionView)
        }
    }
    
    //Needs to be an integer to work properly
    @IBInspectable var itemsPerRow: CGFloat = 2
    
    fileprivate let SizingCell = CommunityCollectionViewCell.fromNib()
    
    //The sizes for all the items, calculated upfront. Needed so we can ensure that everything in a row is the same height
    fileprivate var sizesForItems = [CGSize]()
    
    func onDidSet(collectionView: UICollectionView) {
        //Register the cell
        let nib = UINib(nibName: CommunityCollectionViewCell.Identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CommunityCollectionViewCell.Identifier)
    }
    
    fileprivate func textForCell(at indexPath: IndexPath) -> String {
        return delegate.getCommunities()[indexPath.row].name
    }
    
    fileprivate func numberOfItems() -> Int {
        return delegate.getCommunities().count
    }
    
    fileprivate func calculateSizesForItems() {
        var itemSizes = [CGSize]()
        for i in 0 ..< numberOfItems() {
            let itemSize = calculateSizeForItem(at: IndexPath(row: i, section: 0))
            itemSizes.append(itemSize)
        }
        sizesForItems = itemSizes
    }
    
    fileprivate func calculateSizeForItem(at indexPath: IndexPath) -> CGSize {
        let widthForItem = self.widthForItem()
        
        guard let sizingCell = SizingCell else {
            return CGSize(width: widthForItem, height: widthForItem)
        }
        
        let nameText = textForCell(at: indexPath)
        sizingCell.set(nameText: nameText)
        
        //Give it an unreasonably tall size but constrain the width so that we can get the actual height constrained to the width
        //http://stackoverflow.com/questions/26143591/specifying-one-dimension-of-cells-in-uicollectionview-using-auto-layout
        let targetSize = CGSize(width: widthForItem, height: 2000)
        let sizeConstrainedToWidth = sizingCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        
        return sizeConstrainedToWidth
    }
    
    fileprivate func widthForItem() -> CGFloat {
        let paddingSpace = ListingCollectionHandler.SectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return widthPerItem
    }
}

extension CommunityPickerCollectionHandler: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let community = delegate.getCommunities()[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityCollectionViewCell.Identifier, for: indexPath) as! CommunityCollectionViewCell
        
        let nameText = textForCell(at: indexPath)
        cell.set(nameText: nameText)
        
        cell.tag = indexPath.row
        ImageManager.sharedInstance.downloadImage(url: community.pictureURL) { image in
            //Make sure the cell hasn't been reused by the time the image is downloaded
            guard cell.tag == indexPath.row else { return }
            
            guard let image = image else { return }
            cell.set(photo: image)
        }
        
        return cell
    }
}

extension CommunityPickerCollectionHandler: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedListing = delegate.getCommunities()[indexPath.row]
        delegate.didSelect(selectedListing)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension CommunityPickerCollectionHandler: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //We need to regenerate the sizes for all the items; the work is done up-front
        if indexPath.row == 0 {
            calculateSizesForItems()
        }
        
        let sizeForThisItem = sizesForItems[indexPath.row]
        
        
        //
        //Make the height of this item the height of the tallest item in the same row
        //
        
        let itemsPerRow = Int(self.itemsPerRow)
        let indexOfFirstItemInRow = Int(floor(Double(indexPath.row / itemsPerRow))) * itemsPerRow
        let indexOfLastItemInRow = indexOfFirstItemInRow + (itemsPerRow - 1)
        
        //TODO: it's inefficient to iterate through all items in the row for each item; that could be refactored to be done just once
        var sizesForItemsInThisItemsRow = [CGSize]()
        for i in indexOfFirstItemInRow...indexOfLastItemInRow {
            if i < sizesForItems.count {
                sizesForItemsInThisItemsRow.append(sizesForItems[i])
            }
        }
        
        let heightOfTallestItemInRow = sizesForItemsInThisItemsRow.max(by: {$0.0.height < $0.1.height})!.height
        
        return CGSize(width: sizeForThisItem.width, height: heightOfTallestItemInRow)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return ListingCollectionHandler.SectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ListingCollectionHandler.SectionInsets.left
    }
}
