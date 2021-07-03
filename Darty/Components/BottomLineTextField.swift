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

class BottomLineTextField: UITextField {
    
    private var bottomBorder = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //MARK: Setup Bottom-Border
        self.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = UIColor.black
        bottomBorder.layer.cornerRadius = Constants.borderHeight / 2
        addSubview(bottomBorder)
        
        //Mark: Setup Anchors
        NSLayoutConstraint.activate([
            bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 6),
            bottomBorder.leftAnchor.constraint(equalTo: leftAnchor),
            bottomBorder.rightAnchor.constraint(equalTo: rightAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: Constants.borderHeight)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(_ flag: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.bottomBorder.backgroundColor = flag ? .systemBlue : .black
        }
    }
}
