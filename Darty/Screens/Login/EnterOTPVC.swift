//
//  EnterOTPVC.swift
//  Darty
//
//  Created by Руслан Садыков on 11.06.2022.
//

import UIKit
import SPAlert
import FirebaseAuth

protocol EnterOTPVCDelegate: AnyObject {
    func resendCodeTapped()
    func didGet(verificationCode: String)
}

final class EnterOTPVC: BaseController {

    // MARK: - Constants
    private enum Constants {
        static let infoTextFont: UIFont? = .sfProDisplay(ofSize: 10, weight: .regular)
        static let resendButtonTitle = "Переотправить код"
    }

    // MARK: - UI Elements
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let acceptButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()

    private let resendCodeButton: DButton = {
        let button = DButton(title: Constants.resendButtonTitle)
        button.addTarget(self, action: #selector(resendCodeAction), for: .touchUpInside)
        button.isEnabled = false
        button.setTitle(Constants.resendButtonTitle, for: .normal)
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
        let otpStackView = OTPStackView(codeLength: context.codeLenght)
        otpStackView.delegate = self
        return otpStackView
    }()


    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var resendTimeCounter = context.resendTime {
        didSet {
            let attrs1: [NSAttributedString.Key: Any] = [
                .font: UIFont.sfProDisplay(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let attrs2: [NSAttributedString.Key: Any] = [
                .font: UIFont.sfProDisplay(ofSize: 14, weight: .semibold),
                .foregroundColor: Colors.Elements.element
            ]
            let attributedString1 = NSMutableAttributedString(string: "Переотправить код ", attributes: attrs1)
            let attributedString2 = NSMutableAttributedString(string: resendTimeCounter.asString(), attributes: attrs2)
            attributedString1.append(attributedString2)
            resendCodeButton.setAttributedTitle(attributedString1, for: .disabled)
        }
    }

    // MARK: - Properties
    weak var delegate: EnterOTPVCDelegate?
    private let context: Context

    // MARK: - Init
    init(context: Context) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Введите код"
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = .systemBackground
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
            make.height.equalTo(DButtonStyle.fill.height)
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

    @objc private func updateCounter() {
        if resendTimeCounter > 0 {
            resendTimeCounter -= 1
        } else {
            resendCodeButton.isEnabled = true
        }
    }

    func errorCodeValidation() {
        view.isUserInteractionEnabled = false
        let alertView = SPAlertView(
            title: "Ошибка проверки кода",
            message: "Проверьте корректность введенных дынных и попробуйте снова",
            preset: .custom(UIImage(.textformat._123))
        )
        alertView.duration = 3
        alertView.dismissByTap = true
        alertView.dismissInTime = true
        alertView.present(haptic: .error) {
            self.view.isUserInteractionEnabled = true
        }
        otpStackView.setAllFieldColor(color: .systemRed)
    }

    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc private func acceptAction() {
        let verificationCode = otpStackView.getOTP()
        delegate?.didGet(verificationCode: verificationCode)
    }

    @objc private func resendCodeAction() {
        delegate?.resendCodeTapped()
        resendTimeCounter = context.resendTime
        resendCodeButton.isEnabled = false
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

fileprivate extension Double {
    func asString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? ""
    }
}

extension EnterOTPVC {
    struct Context {
        let resendTime: Double
        let codeLenght: Int
    }
}
