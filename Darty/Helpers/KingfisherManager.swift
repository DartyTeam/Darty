//
//  KingfisherManager.swift
//  Darty
//
//  Created by Руслан Садыков on 19.03.2022.
//

import UIKit
import SkeletonView

class KingfisherManager {

    private init() {}

    static func setImage(for imageView: UIImageView, with url: URL, completion: ((UIImage) -> Void)? = nil) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .transition(.fade(2)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
//                imageView.focusOnFaces = true
                completion?(value.image)
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
            imageView.hideSkeleton()
        }
    }
}

extension UIImageView {
    func setImage(url: URL, completion: ((UIImage) -> Void)? = nil) {
        KingfisherManager.setImage(for: self, with: url, completion: completion)
    }

    func setImage(stringUrl: String, completion: ((UIImage) -> Void)? = nil) {
        guard let url = URL(string: stringUrl) else {
            print("ERROR_LOG Error get url for stringUrl: ", stringUrl)
            return
        }
        KingfisherManager.setImage(for: self, with: url, completion: completion)
    }
}
