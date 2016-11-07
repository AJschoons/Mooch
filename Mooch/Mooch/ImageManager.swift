//
//  ImageManager.swift
//  Mooch
//
//  Created by adam on 10/6/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import AlamofireImage

//Singleton for managing the download of images
class ImageManager {
    
    //The variable to access this class through
    static let sharedInstance = ImageManager()
    
    static let PlaceholderImage = Image(named: "placeholder")
    
    //This prevents others from using the default '()' initializer for this class
    fileprivate init() {}
    
    private let imageDownloader = ImageDownloader()
    
    func removeFromCache(imageURLString urlString: String) {
        guard let imageCache = imageDownloader.imageCache, let imageURL = URL(string: urlString) else { return }
        let imageRequest = URLRequest(url: imageURL)
        imageCache.removeImage(for: imageRequest, withIdentifier: nil)
    }
    
    func clearCache() {
        guard let imageCache = imageDownloader.imageCache else { return }
        imageCache.removeAllImages()
    }
    
    func downloadImage(url: String, completion: @escaping ((Image?) -> ())) {
        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }
        
        let imageRequest = URLRequest(url: imageURL)
        imageDownloader.download(imageRequest) { response in
            guard let image = response.result.value else {
                completion(nil)
                return
            }
            
            completion(image)
        }
    }
}
