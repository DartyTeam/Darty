//
//  SignInVC.swift
//  Darty
//
//  Created by Руслан Садыков on 04.07.2021.
//

import UIKit
import FirebaseAuth
import PhoneNumberKit
import SPAlert

final class SignInVC: BaseController, AuthUIDelegate {

    weak var coordinator: AuthCoordinator?
    
    // MARK: - Constants
    private enum Constants {
        static let infoTextFont: UIFont? = .sfProDisplay(ofSize: 10, weight: .regular)
        static let textFieldFont: UIFont? = .sfProText(ofSize: 25, weight: .medium)
    }

    // MARK: - UI Elements
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let acceptButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.infoTextFont
        label.text = "На ваш номер будет отправлено смс с кодом подтверждения, которое будет необходимо ввести на следующем этапе"
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let phoneNumberKit = PhoneNumberKit()
    
    private lazy var phoneTextField: PhoneNumberTF = {
        let textField = PhoneNumberTF(color: .systemPurple)
        textField.withFlag = true
        textField.withPrefix = true
        textField.withExamplePlaceholder = true
        textField.font = Constants.textFieldFont
        textField.maxDigits = 10
        textField.flagButton.addTarget(self, action: #selector(openCountrySelector), for: .touchUpInside)
        return textField
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var enterOTPVC: EnterOTPVC {
        let context = EnterOTPVC.Context(resendTime: 60, codeLenght: 6)
        let enterOTPVC = EnterOTPVC(context: context)
        enterOTPVC.delegate = self
        return enterOTPVC
    }
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Введите номер"
        clearNavBar = false
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(acceptButton)
        view.addSubview(dartyLogo)
        view.addSubview(warningLabel)
        view.addSubview(containerView)
        containerView.addSubview(phoneTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            acceptButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            acceptButton.heightAnchor.constraint(equalToConstant: UIButton.defaultButtonHeight),
            acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44)
        ])
        
        NSLayoutConstraint.activate([
            dartyLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 112),
            dartyLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            warningLabel.bottomAnchor.constraint(equalTo: acceptButton.topAnchor, constant: -33),
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(lessThanOrEqualTo: dartyLogo.bottomAnchor),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: warningLabel.topAnchor)
        ])
        
        phoneTextField.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(264)
        }
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func acceptAction(isNoNeedShowEnterOTP: Bool = false) {
        if let phone = phoneTextField.text {
            if phoneNumberKit.isValidPhoneNumber(phone) {
                print("asdijoasjoidoasdojias: ", phone)
                AuthService.shared.sendSmsCodeFor(phoneNumber: phone, uiDelegate: self) { result in
                    switch result {
                    case .success:
                        print("Successfull send sms code for number: \(phone)")
                        print("aspodkasiodksaiodasiodjasiodajsdoiasjdoiasd: ", isNoNeedShowEnterOTP)
                        guard !isNoNeedShowEnterOTP else { return }
                        self.navigationController?.pushViewController(self.enterOTPVC, animated: true)
                    case .failure(let error):
                        SPAlert.present(title: "Ошибка", message: error.localizedDescription, preset: .error)
                    }
                }
            } else {
                SPAlert.present(title: "Введен некорректный номер телефона", preset: .error)
            }
        } else {
            print("ERROR_LOG Error get phone number")
        }
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

    private func startSetupProfile(for user: User) {
        SPAlert.present(
            title: "Успешно",
            message: "Осталось заполнить профиль",
            preset: .custom(UIImage(.face.smiling)),
            haptic: .success
        ) {
            self.view.isUserInteractionEnabled = true
            self.coordinator?.startSetupProfile(for: user)
        }
    }

    private func didSuccessfullLogin(with user: UserModel) {
        SPAlert.present(
            title: "Успешно",
            message: "Вы авторизованы",
            preset: .custom(UIImage(.face.smiling)),
            haptic: .success
        ) {
            self.view.isUserInteractionEnabled = true
            self.coordinator?.changeToMainFlow(with: user)
        }
    }
}

extension SignInVC: EnterOTPVCDelegate {
    func resendCodeTapped() {
        acceptAction(isNoNeedShowEnterOTP: true)
    }

    func didGet(verificationCode: String) {
        self.view.isUserInteractionEnabled = false
        AuthService.shared.login(
            with: .phone(verificationCode: verificationCode),
            viewController: self,
            authAlertDelegate: self) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        FirestoreService.shared.getUserData(user: user) { (result) in
                            switch result {
                            case .success(let user):
                                self?.didSuccessfullLogin(with: user)
                            case .failure:
                                self?.startSetupProfile(for: user)
                            }
                        }
                    case .failure(let error):
                        print("ERROR_LOG Error login with verificationCode \(verificationCode): ", error.localizedDescription)
                        self?.view.isUserInteractionEnabled = true
                        self?.enterOTPVC.errorCodeValidation()
                    }
                }
            }
    }
}

extension SignInVC: AuthAlertDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
