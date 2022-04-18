//
//  ChangePhoneVC.swift
//  Darty
//
//  Created by Руслан Садыков on 13.09.2021.
//

import UIKit
import Lottie
import Agrume
import SPAlert
import MessageUI
import PhoneNumberKit

final class ChangePhoneVC: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let textFieldFont: UIFont? = .sfProText(ofSize: 25, weight: .medium)
        static let acceptButtonPlaceholder = "Подтвердить"
    }
    
    // MARK: - UI Elements
    private let phoneAnimationView = AnimationView(name: "SendMail")
    
    private let phoneNumberKit = PhoneNumberKit()

    private let enterPhoneStackView = UIStackView(arrangedSubviews: [], axis: .vertical, spacing: 16)

    private lazy var phoneTextField: PhoneNumberTF = {
        let textField = PhoneNumberTF(color: .systemIndigo)
        textField.withFlag = true
        textField.withPrefix = true
        textField.withExamplePlaceholder = true
        textField.font = Constants.textFieldFont
        textField.maxDigits = 10
        textField.flagButton.addTarget(self, action: #selector(openCountrySelector), for: .touchUpInside)
        textField.delegate = self
        return textField
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProText(ofSize: 16, weight: .regular)
        label.text = "Введите валидный номер телефона"
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()

    private let acceptButton: DButton = {
        let button = DButton(title: Constants.acceptButtonPlaceholder)
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhone()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.phoneAnimationView.play()
        }
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        setNavigationBar(withColor: .systemIndigo, title: "Номер телефона")
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(phoneAnimationView)
        enterPhoneStackView.addArrangedSubview(phoneTextField)
        enterPhoneStackView.addArrangedSubview(errorLabel)
        view.addSubview(enterPhoneStackView)
        view.addSubview(acceptButton)
    }
    
    private func setupConstraints() {
        phoneAnimationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.right.equalToSuperview().inset(76)
            make.height.equalTo(223)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.width.equalTo(view.frame.size.width - 40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            make.height.equalTo(UIButton.defaultButtonHeight)
        }

        enterPhoneStackView.snp.makeConstraints { make in
            make.bottom.equalTo(acceptButton.snp.top).offset(-44)
            make.left.right.equalToSuperview().inset(20)
        }
    }

    private func setupPhone() {
        phoneTextField.text = FirestoreService.shared.currentUser.phone
        phoneTextField.updateFlag()
        acceptButton.isEnabled = phoneTextField.isValidNumber
    }
    
    // MARK: - Handlers
    @objc private func acceptAction() {
        
    }
    
    @objc private func openCountrySelector() {
        let alert = UIAlertController(style: .actionSheet, title: "Коды стран")
        alert.addLocalePicker(type: .phoneCode) { [weak self] info in
            if let country = CountryCodePickerViewController.Country(for: info!.code, with: PhoneNumberKit()) {
                self?.phoneTextField.text = (self?.isEditing ?? false) ? "+" + country.prefix : ""
                self?.phoneTextField.partialFormatter.defaultRegion = country.code
                self?.phoneTextField.updateFlag()
                self?.phoneTextField.updatePlaceholder()
            } else {
                SPAlert.present(title: "Код страны отсуствует в базе данных Google. Используйте страну с аналогичным кодом", preset: .error)
            }
        }
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
}

extension ChangePhoneVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        print("asdijasidojasiod: ", newText)
        textField.text = newText
        let isValidPhoneNumber = (textField as? PhoneNumberTF)?.isValidNumber ?? false
        acceptButton.isEnabled = isValidPhoneNumber
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.isHidden = isValidPhoneNumber
        }
        return true
    }
}
