//
//  CommunityListingsManager.swift
//  Mooch
//
//  Created by adam on 10/20/16.
//  Copyright © 2016 cse498. All rights reserved.
//

//Singleton for managing all the listings within a community
class CommunityListingsManager {
    
    enum CommunityListingsManagerError: Error {
        case noLocalUserCommunityId
    }
    
    //The variable to access this class through
    static let sharedInstance = CommunityListingsManager()
    
    //These variables are calculated each time all the listings change; saves us from doing work every time they are accessed
    var listingsVisibleToCurrentUserInCurrentCommunity: [Listing] { get { return _listingsVisibleToCurrentUserInCurrentCommunity} }
    var listingsOwnedByCurrentUser: [Listing] { get { return _listingsOwnedByCurrentUser} }
    var listingsCurrentUserHasContacted: [Listing] { get { return _listingsCurrentUserHasContacted} }
    
    //Note: These variables should NOT be modified directly; only through the "updateAllListingsInCurrentCommunity" function
    private var _allListingsInCurrentCommunity = [Listing]()
    private var _listingsVisibleToCurrentUserInCurrentCommunity = [Listing]()
    private var _listingsOwnedByCurrentUser = [Listing]()
    private var _listingsCurrentUserHasContacted = [Listing]()
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() { }
    
    //Loads the listings in the current community that haven't been posted by the current user
    //The completion Bool is true on success, false on failure
    func loadListingsForCurrentCommunityAndUser(completion: @escaping ((Bool, Error?)->())) {
        guard let userCommunityId = LocalUserManager.sharedInstance.userCommunityId else { return }
        
        MoochAPI.GETListings(communityId: userCommunityId) { [unowned self] listings, error in
            guard let newListings = listings else {
                completion(false, error)
                return
            }
            
            self.updateAllListingsInCurrentCommunity(with: newListings)
            
            completion(true, nil)
        }
    }
    
    func updateInformation(for updatedListing: Listing) {
        guard let indexOfListingToUpdate = _allListingsInCurrentCommunity.index(where: {$0.id == updatedListing.id}) else {
            return
        }
        
        _allListingsInCurrentCommunity[indexOfListingToUpdate] = updatedListing
        
        updateAllListingsInCurrentCommunity(with: _allListingsInCurrentCommunity)
    }
    
    func allListingsOwned(by user: User) -> [Listing] {
        return _allListingsInCurrentCommunity.filter({$0.owner.id == user.id})
    }
    
    fileprivate func updateAllListingsInCurrentCommunity(with newListings: [Listing]) {
        
        _allListingsInCurrentCommunity = newListings
        
        
        //
        //Default values for when there ISN'T a user logged in
        //
        
        var listingsVisibleToCurrentUserInCurrentCommunity = newListings
        var listingsOwnedByCurrentUser = [Listing]()
        var listingsCurrentUserHasContacted = [Listing]()
        
        
        //
        //If the user is logged in...
        //
        
        if let localUser = LocalUserManager.sharedInstance.localUser {
            //Filter to only show listings this user hasn't posted
            listingsVisibleToCurrentUserInCurrentCommunity = listingsVisibleToCurrentUserInCurrentCommunity.filter({$0.owner.id != localUser.user.id})
            
            //Filter to only show listings this user has posted
            listingsOwnedByCurrentUser = allListingsOwned(by: localUser.user)
            
            //Filter to only show listings this user has contacted
            listingsCurrentUserHasContacted = listingsCurrentUserHasContacted.filter({$0.isOwnerContactedBy(by: localUser.user)})
        }
        
        
        //
        //Finally, save the results
        //
        
        _listingsVisibleToCurrentUserInCurrentCommunity = listingsVisibleToCurrentUserInCurrentCommunity
        _listingsOwnedByCurrentUser = listingsOwnedByCurrentUser
        _listingsCurrentUserHasContacted = listingsVisibleToCurrentUserInCurrentCommunity
    }
}
