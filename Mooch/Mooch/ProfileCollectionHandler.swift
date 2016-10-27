//
//  ProfileCollectionHandler.swift
//  Mooch
//
//  Created by adam on 10/25/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import GSKStretchyHeaderView
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
    
    private(set) var headerView: ProfileCollectionHeaderView!
    
    let ZeroScrollContentOffset = CGPoint(x: 0, y: -ProfileCollectionHeaderView.EstimatedHeight)
    
    override func onDidSet(collectionView: UICollectionView) {
        super.onDidSet(collectionView: collectionView)
        
        setupHeaderView(in: collectionView)
        reloadHeaderView()
    }
    
    func reloadData() {
        guard let collectionView = collectionView else { return }
        
        collectionView.reloadData()
        reloadHeaderView()
        
        if delegate.getListings().count == 0 {
            collectionView.isScrollEnabled = false
            collectionView.setContentOffset(ZeroScrollContentOffset, animated: true)
            collectionView.backgroundView = createNoListingsBackgroundView()
        } else {
            collectionView.isScrollEnabled = true
            collectionView.backgroundView = nil
        }
    }
    
    func resetScrollPosition() {
        guard let collectionView = collectionView else { return }
        collectionView.setContentOffset(ZeroScrollContentOffset, animated: false)
    }
    
    fileprivate func setupHeaderView(in collectionView: UICollectionView) {
        collectionView.layoutIfNeeded()
        
        let height = ProfileCollectionHeaderView.EstimatedHeight - 64 //Subtracted by tab bar height because this stretchy header library just adds that in for some reason
        let headerSize = CGSize(width: collectionView.frame.width, height: height)
        headerView = ProfileCollectionHeaderView(frame: CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height))
        headerView.contentAnchor = GSKStretchyHeaderViewContentAnchor.bottom
        headerView.minimumContentHeight = 64 + 35 //Nav bar plus height of header control
        //headerView.maximumContentHeight = ProfileCollectionHeaderView.EstimatedHeight + 50
        headerView.contentExpands = false
        //headerView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        collectionView.addSubview(headerView)
        
        headerView.bottomBarDoubleSegmentedControl.delegate = delegate
        headerView.bottomBarDoubleSegmentedControl.set(title: "My Listings", for: .first)
        headerView.bottomBarDoubleSegmentedControl.set(title: "Contact History", for: .second)
        headerView.setup(for: delegate.getConfiguration().mode)
    }
    
    fileprivate func reloadHeaderView() {
        let user = delegate.getUser()
        guard let profileUser = user else { return }
        
        headerView.userNameLabel.text = profileUser.name
        
        var communityText = ""
        if let currentCommunity = CommunityManager.sharedInstance.getCommunity(withId: profileUser.communityId) {
            communityText = currentCommunity.name
        }
        headerView.userCommunityLabel.text = communityText
        
        headerView.userImageView.image = UIImage(named: "defaultProfilePhoto")
        
        if let profilePhotoURL = profileUser.pictureURL {
            ImageManager.sharedInstance.downloadImage(url: profilePhotoURL) { [weak self] image in
                guard let image = image else { return }
                self?.headerView.userImageView.image = image
            }
        }
        
        headerView.layoutIfNeeded()
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
    
    fileprivate func isInvisibleItem(at index: IndexPath) -> Bool {
        return index.row > (delegate.getListings().count - 1)
    }
}

//MARK: UICollectionViewDataSource
extension ProfileCollectionHandler {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(delegate.getListings().count, 6)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCollectionViewCell.Identifier, for: indexPath) as! ListingCollectionViewCell
        cell.alpha = 1.0
        cell.isUserInteractionEnabled = true
        
        guard !isInvisibleItem(at: indexPath) else {
            cell.alpha = 0.0
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let listing = delegate.getListings()[indexPath.row]
        cell.set(bottomLabelText: listing.priceString)
        
        cell.tag = indexPath.row
        
        if let localPhoto = listing.photo {
            cell.set(photo: localPhoto)
        } else {
            ImageManager.sharedInstance.downloadImage(url: listing.thumbnailPictureURL) { image in
                //Make sure the cell hasn't been reused by the time the image is downloaded
                guard cell.tag == indexPath.row else { return }
                
                guard let image = image else { return }
                cell.set(photo: image)
            }
        }
        
        return cell
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
    
}
