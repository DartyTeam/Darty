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

    static func setImage(for imageView: UIImageView,
                         with url: URL,
                         completion: ((Result<UIImage, Error>) -> Void)? = nil) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
//                imageView.focusOnFaces = true
                DispatchQueue.main.async {
                    completion?(.success(value.image))
                }
            case .failure(let error):
                print("ERROR_LOG Error load image for url: \(url): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
            imageView.hideSkeleton()
        }
    }
}

extension UIImageView {
    func setImage(url: URL, completion: ((Result<UIImage, Error>) -> Void)? = nil) {
        KingfisherManager.setImage(for: self, with: url, completion: completion)
    }

    func setImage(stringUrl: String, completion: ((Result<UIImage, Error>) -> Void)? = nil) {
        guard let url = URL(string: stringUrl) else {
            print("ERROR_LOG Error get url for stringUrl: ", stringUrl)
            completion?(.failure(URLError.errorGetUrlFromString))
            return
        }
        KingfisherManager.setImage(for: self, with: url, completion: completion)
    }
}
