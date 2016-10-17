//
//  ListingsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingsCollectionHandlerDelegate: class {
    func getListings() -> [Listing]
    func didSelect(_ listing: Listing)
    func refresh()
}

class ListingsCollectionHandler: ListingCollectionHandler {
    
    private var refreshControl: UIRefreshControl!
    
    weak var delegate: ListingsCollectionHandlerDelegate!
    
    override func onDidSet(collectionView: UICollectionView) {
        super.onDidSet(collectionView: collectionView)
        
        collectionView.allowsSelection = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
    }
    
    func updateUI() {
        collectionView.reloadData()
    }
    
    func onRefresh() {
        delegate.refresh()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}

//MARK: UICollectionViewDataSource
extension ListingsCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.getListings().count
    }
    
    //Subclasses should override
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let listing = delegate.getListings()[(indexPath as NSIndexPath).row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCollectionViewCell.Identifier, for: indexPath) as! ListingCollectionViewCell
        
        cell.set(bottomLabelText: listing.priceString)
        
        cell.tag = indexPath.row
        //cell.photo.image = ImageManager.PlaceholderImage
        ImageManager.sharedInstance.downloadImage(url: listing.thumbnailPictureURL) { image in
            //Make sure the cell hasn't been reused by the time the image is downloaded
            guard cell.tag == indexPath.row else { return }
            
            guard let image = image else { return }
            cell.set(photo: image)
        }
        
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension ListingsCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedListing = delegate!.getListings()[(indexPath as NSIndexPath).row]
        delegate!.didSelect(selectedListing)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
