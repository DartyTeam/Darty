//
//  PhoneNumberTextField + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 04.09.2021.
//

import Foundation
import PhoneNumberKit

class PhoneNumberTF: PhoneNumberTextField {
    
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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    func select(_ flag: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.bottomBorder.backgroundColor = flag ? self.color : .systemGray
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        self.select(true)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        self.select(true)
    }
}
