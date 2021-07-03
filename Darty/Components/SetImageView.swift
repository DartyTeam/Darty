//
//  SetImageView.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

import UIKit

protocol SetImageDelegate {
    func showPicker(picker: UIPickerView)
}

final class SetImageView: BlurEffectView {
    
    // MARK: - UI Elements
    let plusIcon: UIImageView = {
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50, weight: .medium))
        let imageView = UIImageView(image: UIImage(systemName: "plus.viewfinder", withConfiguration: configIcon))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Properties
    private var delegate: SetImageDelegate!
    
    // MARK: - Lifecycle
    init(delegate: SetImageDelegate) {
        self.delegate = delegate
        super.init(effect: nil)
        
        setupView()
        setupConstraints()
        addTap()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    private func setupView() {
        layer.cornerRadius = 40
        clipsToBounds = true
        layer.borderWidth = 3.5
        layer.borderColor = UIColor.systemBlue.cgColor
        
        contentView.addSubview(plusIcon)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            plusIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            plusIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
    
 
    
    
    
    // MARK: - Handlers
    @objc func viewTapped() {
      showAnimation {
        
      }
    }
}
