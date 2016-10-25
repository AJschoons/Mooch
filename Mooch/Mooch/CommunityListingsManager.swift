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
    
    private(set) var listingsInCurrentCommunity = [Listing]()
    
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
            
            //Filter to only show listings this user hasn't posted
            var listingsNotPostedByThisUser = newListings
            if let localUser = LocalUserManager.sharedInstance.localUser {
                listingsNotPostedByThisUser = listingsNotPostedByThisUser.filter({$0.owner.id != localUser.user.id})
            }
            
            self.listingsInCurrentCommunity = listingsNotPostedByThisUser
            
            completion(true, nil)
        }
    }
    
    func updateInformation(for updatedListing: Listing) {
        guard let indexOfListingToUpdate = listingsInCurrentCommunity.index(where: {$0.id == updatedListing.id}) else {
            return
        }
        
        listingsInCurrentCommunity[indexOfListingToUpdate] = updatedListing
    }
}
