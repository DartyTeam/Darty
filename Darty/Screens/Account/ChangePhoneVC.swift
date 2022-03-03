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
    }
    
    // MARK: - UI Elements
    private let phoneAnimationView = AnimationView(name: "SendMail")
    
    private let phoneNumberKit = PhoneNumberKit()
    
    private lazy var phoneTextField: PhoneNumberTF = {
        let textField = PhoneNumberTF(color: .systemIndigo)
        textField.withFlag = true
        textField.withPrefix = true
        textField.withExamplePlaceholder = true
        textField.font = Constants.textFieldFont
        textField.maxDigits = 10
        textField.flagButton.addTarget(self, action: #selector(openCountrySelector), for: .touchUpInside)
        return textField
    }()

    private let acceptButton: UIButton = {
        let button = UIButton(title: "Подтвердить")
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        setNavigationBar(withColor: .systemIndigo, title: "Связь с разработчиком")
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(phoneAnimationView)
        view.addSubview(phoneTextField)
        view.addSubview(acceptButton)
    }
    
    private func setupConstraints() {
        phoneAnimationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.right.equalToSuperview().inset(76)
            make.height.equalTo(223)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneAnimationView.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(44)
            make.left.right.equalToSuperview().inset(20)
            make.width.equalTo(view.frame.size.width - 40)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Handlers
    @objc private func acceptAction() {
        
    }
    
    @objc private func sendEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            SPAlert.present(title: "Не найдено почтовых клиентов на устройстве", message: "Пожалуйста добавьте учетную запись в приложении Почта, либо скачайте и настройке сторонний почтовый клиент", preset: .error)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self        
        mailComposeVC.setToRecipients(["s.ru5c55an.n@gmail.com"])
        mailComposeVC.setSubject("Message from DartyApp")
//        mailComposeVC.setMessageBody(messageTextView.text, isHTML: false)
        return mailComposeVC
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

// MARK: - MFMailComposeViewControllerDelegate
extension ChangePhoneVC: MFMailComposeViewControllerDelegate {
    private func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
            SPAlert.present(title: "Письмо сохранено", preset: .done)
        case .sent:
            print("Mail sent")
            SPAlert.present(title: "Письмо отправлено", preset: .done)
        case .failed:
            print("Mail sent failure: \(error?.localizedDescription ?? "")")
            SPAlert.present(title: error?.localizedDescription ?? "Неизвестная ошибка", preset: .error)
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
