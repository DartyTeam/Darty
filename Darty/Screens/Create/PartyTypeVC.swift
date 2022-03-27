//
//  PartyTypeVC.swift
//  Darty
//
//  Created by Руслан Садыков on 12.07.2021.
//

import UIKit

final class PartyTypeVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let textFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
    }
    
    // MARK: - UI Elements
    private let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var typePicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(PartyType.allCases.count / 2, inComponent: 0, animated: false)
        return pickerView
    }()

    // MARK: - Properties
    private var pickedType = PartyType.allCases.first!
    
    // MARK: - Delegate
    weak var delegate: PartyTypeDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupNavBar() {
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        let cancelIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let cancelIconImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: cancelIconConfig)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelIconImage, style: .plain, target: self, action: #selector(cancleAction))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(logoView)
        view.addSubview(nextButton)
        view.addSubview(typePicker)
    }
    
    // MARK: - Handlers
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func nextButtonTapped() {
        delegate?.goNext(with: pickedType)
    }
}

// MARK: - Setup constraints
extension PartyTypeVC {
    private func setupConstraints() {
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        typePicker.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
            make.left.right.equalToSuperview().inset(20)
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension PartyTypeVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PartyType.allCases.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PartyType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedType = PartyType.allCases[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
//        label.textColor = .black
        label.textAlignment = .center
        label.font = .sfProDisplay(ofSize: 18, weight: .semibold)
        
        // where data is an Array of String
        label.text = PartyType.allCases[row].rawValue
        
        return label
    }
}
