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
}

class ListingsCollectionHandler: ListingCollectionHandler {
    
    fileprivate let HeightForHeader: CGFloat = 40
    
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
        isRefreshing = true
        
        delegate.refresh()
        
        guard endRefreshingAfterMinimumDurationTimer == nil else { return }
        endRefreshingAfterMinimumDurationTimer = ExecuteActionAfterMinimumDurationTimer(minimumDuration: 1.0)
    }
    
    func endRefreshingAndReloadData() {
        guard let timer = endRefreshingAfterMinimumDurationTimer else { return }
        timer.execute() { [weak self] in
            self?.isRefreshing = false
            self?.reloadData()
            self?.refreshControl.endRefreshing()
            self?.endRefreshingAfterMinimumDurationTimer = nil
        }
    }
    
    fileprivate func createNoListingsBackgroundView() -> UIView
    {
        let backgroundView = UIView(frame: collectionView.bounds)
        backgroundView.backgroundColor = UIColor.clear
        
        let noListingsLabel = UILabel()
        noListingsLabel.numberOfLines = 0
        noListingsLabel.backgroundColor = UIColor.clear
        noListingsLabel.text = delegate.hasListingsButNoneMatchFilter() ?  Strings.Listings.noListingsAfterFilterAppliedLabelText.rawValue : Strings.Listings.noListingsInCommunityLabelText.rawValue
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
    
    //Subclasses should override
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
