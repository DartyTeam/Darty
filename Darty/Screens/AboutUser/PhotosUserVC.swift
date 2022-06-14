//
//  PhotosUserVC.swift
//  Darty
//
//  Created by Руслан Садыков on 26.07.2021.
//

import UIKit
import ComplimentaryGradientView
import Hero

final class PhotosUserVC: BaseController {
    
    // MARK: - UI Elements
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isSkeletonable = true
        return imageView
    }()
    
    private let complimentaryGradientView: ComplimentaryGradientView = {
        let complimentaryGradientView = ComplimentaryGradientView()
        complimentaryGradientView.gradientType = .colors(start: .primary, end: .secondary)
        complimentaryGradientView.gradientStartPoint = .top
        complimentaryGradientView.gradientQuality = .high
        return complimentaryGradientView
    }()
    
    // MARK: - Properties
    private var imageStringUrl: String?
    private let preloadedUserImage: UIImage?
    private let isNeedAnimatedShowImage: Bool
    
    // MARK: - Lifecycle
    init(image: String, preloadedUserImage: UIImage? = nil, isNeedAnimatedShowImage: Bool = true) {
        self.imageStringUrl = image
        self.preloadedUserImage = preloadedUserImage
        self.isNeedAnimatedShowImage = isNeedAnimatedShowImage
        super.init(nibName: nil, bundle: nil)
    }

    init(preloadedUserImage: UIImage? = nil, isNeedAnimatedShowImage: Bool = true) {
        self.preloadedUserImage = preloadedUserImage
        self.isNeedAnimatedShowImage = isNeedAnimatedShowImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHero()
        if let preloadedUserImage = preloadedUserImage {
            imageView.image = preloadedUserImage
            setupGradientAndFocusWith(image: preloadedUserImage)
        } else {
            imageView.showAnimatedGradientSkeleton()
        }
        if let imageStringUrl = imageStringUrl {
            setupWith(imageStringUrl: imageStringUrl)
        }
        setupViews()
        setupConstraints()
    }

    func setupWith(imageStringUrl: String) {
        imageView.setImage(stringUrl: imageStringUrl) { result in
            switch result {
            case .success(let image):
                self.setupGradientAndFocusWith(image: image)
            case .failure:
                #warning("Сделать установку изображения об ошибке загрузки изображения")
            }
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
        view.backgroundColor = Colors.Elements.disabledElement
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
