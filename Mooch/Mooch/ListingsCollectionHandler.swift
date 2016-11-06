//
//  ListingsTableHandler.swift
//  Mooch
//
//  Created by adam on 9/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ListingsCollectionHandlerDelegate: class, ListingsCollectionHeaderViewDelegate {
    func getListings() -> [Listing]
    func didSelect(_ listing: Listing)
    func refresh()
    func hasListingsButNoneMatchFilter() -> Bool
    func shouldAllowPullToRefresh() -> Bool
    func areListingsFromSearch() -> Bool
}

class ListingsCollectionHandler: ListingCollectionHandler {
    
    fileprivate let HeightForHeader: CGFloat = 32
    
    private var refreshControl: UIRefreshControl!
    
    private(set) var isRefreshing = false
    
    weak var delegate: ListingsCollectionHandlerDelegate!
    
    var isCollectionViewSet: Bool {
        return collectionView != nil
    }
    
    override func onDidSet(collectionView: UICollectionView) {
        super.onDidSet(collectionView: collectionView)
        
        if delegate.shouldAllowPullToRefresh() {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
            refreshControl.clipsToBounds = true
            
            collectionView.addSubview(refreshControl)
            collectionView.sendSubview(toBack: refreshControl)
        }
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
        
        if delegate.getListings().count == 0 {
            collectionView.backgroundView = createNoListingsBackgroundView()
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    func onRefresh() {
        guard delegate.shouldAllowPullToRefresh() else { return }
        
        isRefreshing = true
        
        delegate.refresh()
    }
    
    func endRefreshingAndReloadData() {
        guard delegate.shouldAllowPullToRefresh() else { return }
        
        isRefreshing = false
        reloadData()
        refreshControl.endRefreshing()
    }
    
    fileprivate func createNoListingsBackgroundView() -> UIView
    {
        let backgroundView = UIView(frame: collectionView.bounds)
        backgroundView.backgroundColor = UIColor.clear
        
        let noListingsLabel = UILabel()
        
        var text: String = ""
        if delegate.areListingsFromSearch() {
            text = delegate.hasListingsButNoneMatchFilter() ?  Strings.Listings.noListingsMatchingSearchAfterFilterAppliedLabelText.rawValue : Strings.Listings.noListingsInCommunityMatchingSearchLabelText.rawValue
        } else {
            text = delegate.hasListingsButNoneMatchFilter() ?  Strings.Listings.noListingsAfterFilterAppliedLabelText.rawValue : Strings.Listings.noListingsInCommunityLabelText.rawValue
        }
        noListingsLabel.text = text
        
        noListingsLabel.numberOfLines = 0
        noListingsLabel.backgroundColor = UIColor.clear
        noListingsLabel.textColor = UIColor.darkGray
        noListingsLabel.font = UIFont.systemFont(ofSize: 15)
        noListingsLabel.textAlignment = .center
        let labelPadding: CGFloat = 40
        noListingsLabel.frame = CGRect(x: labelPadding, y: 0, width: backgroundView.bounds.width - 2*labelPadding, height: backgroundView.bounds.height)
        
        backgroundView.addSubview(noListingsLabel)
        
        return backgroundView
    }
}

//MARK: UICollectionViewDataSource
extension ListingsCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.getListings().count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let listing = delegate.getListings()[indexPath.row]
        
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ListingsCollectionHeaderView.Identifier, for: indexPath) as! ListingsCollectionHeaderView
        
        if let userCommunityId = LocalUserManager.sharedInstance.userCommunityId {
            if let currentCommunity = CommunityManager.sharedInstance.getCommunity(withId: userCommunityId) {
                headerView.set(communityName: currentCommunity.name)
            }
        }
        
        headerView.delegate = delegate
        
        return headerView
    }
}

//MARK: UICollectionViewDelegate
extension ListingsCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedListing = delegate!.getListings()[indexPath.row]
        delegate!.didSelect(selectedListing)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ListingsCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: HeightForHeader)
    }
}
