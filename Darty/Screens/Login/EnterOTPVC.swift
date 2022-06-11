//
//  EnterOTPVC.swift
//  Darty
//
//  Created by Руслан Садыков on 11.06.2022.
//

import UIKit
import SPAlert
import FirebaseAuth

final class EnterOTPVC: UIViewController {

    weak var coordinator: AuthCoordinator?

    // MARK: - Constants
    private enum Constants {
        static let infoTextFont: UIFont? = .sfProDisplay(ofSize: 10, weight: .regular)
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
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()

    private let resendCodeButton: DButton = {
        let button = DButton(title: "Переотправить код")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(recendCodeAction), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView = UIStackView(arrangedSubviews: [resendCodeButton, acceptButton], axis: .horizontal, spacing: 16)

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.infoTextFont
        label.text = "Подтверждая регистрацию, вы также соглашаетесь с обработкой и хранением ваших персональных данных"
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var otpStackView: OTPStackView = {
        let otpStackView = OTPStackView()
        otpStackView.delegate = self
        return otpStackView
    }()


    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = .systemBackground
        setNavigationBar(withColor: .systemPurple, title: "Введите код", withClear: true)
        buttonsStackView.distribution = .fillEqually
        view.addSubview(buttonsStackView)
        view.addSubview(dartyLogo)
        view.addSubview(warningLabel)
        view.addSubview(containerView)
        containerView.addSubview(otpStackView)
    }

    private func setupConstraints() {
        buttonsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
        }

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

        otpStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(264)
        }
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

    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc private func acceptAction() {
        let verificationCode = otpStackView.getOTP()
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
                        self?.view.isUserInteractionEnabled = true
                        self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                    }
                }
            }
    }

    @objc private func recendCodeAction() {

    }
}

extension EnterOTPVC: AuthAlertDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

extension EnterOTPVC: OTPDelegate {
    func didChangeValidity(isValid: Bool) {
        acceptButton.isEnabled = isValid
    }
}
