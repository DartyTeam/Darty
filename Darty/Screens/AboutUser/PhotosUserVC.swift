//
//  PhotosUserVC.swift
//  Darty
//
//  Created by Руслан Садыков on 26.07.2021.
//

import UIKit
import ComplimentaryGradientView
import Hero

final class PhotosUserVC: UIViewController {
    
    // MARK: - UI Elements
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let complimentaryGradientView: ComplimentaryGradientView = {
        let complimentaryGradientView = ComplimentaryGradientView()
        complimentaryGradientView.gradientType = .colors(start: .primary, end: .secondary)
        
        // Default = `.left`
        complimentaryGradientView.gradientStartPoint = .top
        
        // Default = `.high`
        complimentaryGradientView.gradientQuality = .high
        return complimentaryGradientView
    }()
    
    // MARK: - Properties
    private var imageStringUrl: String
    private let preloadedUserImage: UIImage?
    private let isNeedAnimatedShowImage: Bool
    
    // MARK: - Lifecycle
    init(image: String, preloadedUserImage: UIImage? = nil, isNeedAnimatedShowImage: Bool = true) {
        self.imageStringUrl = image
        self.preloadedUserImage = preloadedUserImage
        self.isNeedAnimatedShowImage = isNeedAnimatedShowImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = preloadedUserImage
        setupGradientAndFocusWith(image: preloadedUserImage)
        setupViews()
        setupConstraints()
        setupHero()
        imageView.setImage(stringUrl: imageStringUrl) { image in
            self.setupGradientAndFocusWith(image: image)
        }
    }

    private func setupGradientAndFocusWith(image: UIImage?) {
        imageView.focusOnFaces = true
        complimentaryGradientView.image = imageView.image
    }

    private func setupHero() {
        self.hero.isEnabled = true
        complimentaryGradientView.hero.modifiers = [.translate(y: 600)]
        guard isNeedAnimatedShowImage else { return }
        imageView.hero.id = GlobalConstants.userImageHeroId
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(complimentaryGradientView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(view.frame.size.width)
        }
        
        complimentaryGradientView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
