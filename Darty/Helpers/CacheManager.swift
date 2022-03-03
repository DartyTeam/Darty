//
//  CacheManager.swift
//  Darty
//
//  Created by Руслан Садыков on 28.08.2021.
//

import Kingfisher
import UIKit

class CacheManager {
    
    private enum Constants {
        static let imageCacheKey = "imageCacheKey"
    }
    
    static let shared = CacheManager()
    
    private init() { }
    
    let cache = ImageCache.default
    lazy var imageCached = cache.isCached(forKey: Constants.imageCacheKey)
    
    func save(image: UIImage) {
        cache.store(image, forKey: Constants.imageCacheKey)
    }
}
