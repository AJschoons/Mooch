//
//  CommunityManager.swift
//  Mooch
//
//  Created by adam on 10/19/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import Foundation

//Singleton for managing the Community models in the app
class CommunityManager {
    
    //The variable to access this class through
    static let sharedInstance = CommunityManager()
    
    private(set) var communities = [Community]()
    
    //Dictionary of a Community's id to the Community for quick Community lookup
    private var idToObjectMapping = [Int : Community]()
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() { }
    
    func update(withCommunities communities: [Community]) {
        self.communities = communities
        generateIdToObjectMapping(forCommunities: communities)
    }
    
    func getCommunity(withId communityId: Int) -> Community? {
        return idToObjectMapping[communityId]
    }
    
    private func generateIdToObjectMapping(forCommunities communities: [Community]) {
        var newIdToObjectMapping = [Int : Community]()
        for community in communities {
            newIdToObjectMapping[community.id] = community
        }
        idToObjectMapping = newIdToObjectMapping
    }
}
