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
    
    //Allows us to ensure that refreshing takes at least a minimim duration; makes the UX smoother
    private var endRefreshingAfterMinimumDurationTimer: ExecuteActionAfterMinimumDurationTimer?
    
    private(set) var isRefreshing = false
    
    weak var delegate: ListingsCollectionHandlerDelegate!
    
    override func onDidSet(collectionView: UICollectionView) {
        super.onDidSet(collectionView: collectionView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        refreshControl.clipsToBounds = true
        
        collectionView.addSubview(refreshControl)
        collectionView.sendSubview(toBack: refreshControl)
        
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func onRefresh() {
        isRefreshing = true
        
        delegate.refresh()
        
        guard endRefreshingAfterMinimumDurationTimer == nil else { return }
        endRefreshingAfterMinimumDurationTimer = ExecuteActionAfterMinimumDurationTimer(minimumDuration: 1.0)
    }
    
    func endRefreshingAndReloadData() {
        guard let timer = endRefreshingAfterMinimumDurationTimer else { return }
        timer.execute() { [weak self] in
            self?.isRefreshing = false
            self?.collectionView.reloadData()
            self?.refreshControl.endRefreshing()
            self?.endRefreshingAfterMinimumDurationTimer = nil
        }
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
