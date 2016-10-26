//
//  ProfileCollectionHandler.swift
//  Mooch
//
//  Created by adam on 10/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol ProfileCollectionHandlerDelegate: class, BottomBarDoubleSegmentedControlDelegate {
    
    typealias Configuration = ProfileConfiguration
    
    func getUser() -> User?
    func getListings() -> [Listing]
    func getConfiguration() -> Configuration
    func didSelect(_ listing: Listing)
    func getInsetForTabBar() -> CGFloat
}

class ProfileCollectionHandler: ListingCollectionHandler {
    
    weak var delegate: ProfileCollectionHandlerDelegate!
    
    override func onDidSet(collectionView: UICollectionView) {
        super.onDidSet(collectionView: collectionView)
        
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
    
    fileprivate func createNoListingsBackgroundView() -> UIView
    {
        let backgroundView = UIView(frame: collectionView.bounds)
        backgroundView.backgroundColor = UIColor.clear
        
        let noListingsLabel = UILabel()
        noListingsLabel.text = Strings.Profile.noListings.rawValue
        
        noListingsLabel.numberOfLines = 0
        noListingsLabel.backgroundColor = UIColor.clear
        noListingsLabel.textColor = UIColor.darkGray
        noListingsLabel.font = UIFont.systemFont(ofSize: 15)
        noListingsLabel.textAlignment = .center
        
        let labelY = ProfileCollectionHeaderView.EstimatedHeight
        let labelHeight = backgroundView.bounds.height - ProfileCollectionHeaderView.EstimatedHeight
        let labelPadding: CGFloat = 40
        noListingsLabel.frame = CGRect(x: labelPadding, y: labelY, width: backgroundView.bounds.width - 2*labelPadding, height: labelHeight)
        
        backgroundView.addSubview(noListingsLabel)
        
        return backgroundView
    }
}

//MARK: UICollectionViewDataSource
extension ProfileCollectionHandler {
    
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
        let user = delegate.getUser()
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ProfileCollectionHeaderView.Identifier, for: indexPath) as! ProfileCollectionHeaderView
        
        guard let profileUser = user else {
            return headerView
        }
        
        
        headerView.bottomBarDoubleSegmentedControl.delegate = delegate
        headerView.bottomBarDoubleSegmentedControl.set(title: "My Listings", for: .first)
        headerView.bottomBarDoubleSegmentedControl.set(title: "Contact History", for: .second)
        headerView.setup(for: delegate.getConfiguration().mode)
        
        headerView.userNameLabel.text = profileUser.name
        
        var communityText = ""
        if let currentCommunity = CommunityManager.sharedInstance.getCommunity(withId: profileUser.communityId) {
            communityText = currentCommunity.name
        }
        headerView.userCommunityLabel.text = communityText
        
        headerView.userImageView.image = UIImage(named: "defaultProfilePhoto")
        
        if let profilePhotoURL = profileUser.pictureURL {
            ImageManager.sharedInstance.downloadImage(url: profilePhotoURL) { image in
                guard let image = image else { return }
                headerView.userImageView.image = image
            }
        }
        
        return headerView
    }
}

//MARK: UICollectionViewDelegate
extension ProfileCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedListing = delegate!.getListings()[indexPath.row]
        delegate!.didSelect(selectedListing)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ProfileCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: ProfileCollectionHeaderView.EstimatedHeight)
    }
}
