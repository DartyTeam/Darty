//
//  BottomLineTextField.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

class BottomLineTextField: UITextField {

    // MARK: - Constants
    private enum Constants {
        static let borderHeight: CGFloat = 4
    }

    // MARK: - UI Elements
    private var bottomBorder: UIView = {
        let view = UIView()
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

        textColor = color
        tintColor = color

        bottomBorder.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(4)
            make.height.equalTo(Constants.borderHeight)
            make.bottom.equalToSuperview().offset(6)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    func select(_ flag: Bool) {
        print("asd978as7y8das67d6a7sd")
        UIView.animate(withDuration: 0.3) {
            self.bottomBorder.backgroundColor = flag ? self.color : .systemGray
        }
    }

    func setErrorBottomColor() {
        print("asduiasduasdiuasduahsdasuidsuahiasdsad")
        UIView.animate(withDuration: 0.3) {
            self.bottomBorder.backgroundColor = .systemRed
        }
    }
}
