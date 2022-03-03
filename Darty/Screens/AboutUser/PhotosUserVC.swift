//
//  PhotosUserVC.swift
//  Darty
//
//  Created by Руслан Садыков on 26.07.2021.
//

import UIKit
import ComplimentaryGradientView

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
    
    // MARK: - Lifecycle
    init(image: String) {
        self.imageStringUrl = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let imageUrl = URL(string: imageStringUrl) else { return }
        StorageService.shared.downloadImage(url: imageUrl) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageView.image = image
                self?.imageView.focusOnFaces = true
                self?.complimentaryGradientView.image = self?.imageView.image
            case .failure(let error):
                print("ERROR_LOG: ", error.localizedDescription)
            }
        }
        setupViews()
        setupConstraints()
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
