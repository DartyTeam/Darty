//
//  BottomLineTextField.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

private enum Constants {
    static let borderHeight: CGFloat = 4
}

final class BottomLineTextField: UITextField {
    
    // MARK: - UI Elements
    private var bottomBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = Constants.borderHeight / 2
        return view
    }()
    
    // MARK: - Properties
    private let color: UIColor!
    
    // MARK: - Lifecycle
    init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        addSubview(bottomBorder)

        NSLayoutConstraint.activate([
            bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 6),
            bottomBorder.leftAnchor.constraint(equalTo: leftAnchor, constant: -4),
            bottomBorder.rightAnchor.constraint(equalTo: rightAnchor, constant: 4),
            bottomBorder.heightAnchor.constraint(equalToConstant: Constants.borderHeight)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    func select(_ flag: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.bottomBorder.backgroundColor = flag ? self.color : .systemGray
        }
    }
}
