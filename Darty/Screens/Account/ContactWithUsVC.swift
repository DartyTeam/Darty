//
//  ContactWithUsVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.08.2021.
//

import UIKit
import Lottie
import Agrume
import PhotosUI
import SPAlert
import MessageUI

final class ContactWithUsVC: UIViewController {
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private let mailAnimationView = AnimationView(name: "SendMail")
    
    private let messageTextView: TextView = {
        let textView = TextView(placeholder: "Сообщение", isEditable: true, color: .systemIndigo)
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(title: "Отправить")
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        return button
    }()
    
    private let attachImagesLabel: UILabel = {
        let label = UILabel()
        label.text = "Прикрепить изображения"
        label.font = .sfProDisplay(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var attachImagesView: MultiSetImagesView = {
        let multiSetImagesView = MultiSetImagesView(maxPhotos: 10, shape: .rect, color: .systemIndigo)
        multiSetImagesView.numberOfItemInPage = 3
        multiSetImagesView.delegate = self
        multiSetImagesView.isPagingEnabled = false
        return multiSetImagesView
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
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        setNavigationBar(withColor: .systemIndigo, title: "Связь с разработчиком")
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(mailAnimationView)
        view.addSubview(scrollView)
        scrollView.addSubview(messageTextView)
        scrollView.addSubview(sendButton)
        scrollView.addSubview(attachImagesLabel)
        scrollView.addSubview(attachImagesView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mailAnimationView.play()
        }
    }
    
    private func setupConstraints() {
        mailAnimationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.right.equalToSuperview().inset(76)
            make.height.equalTo(223)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(mailAnimationView.snp.bottom).offset(32)
            make.edges.equalToSuperview()
        }
        
        messageTextView.snp.makeConstraints { make in
            make.top.equalTo(mailAnimationView.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(128)
        }
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(messageTextView.snp.bottom).offset(44)
            make.left.right.equalToSuperview().inset(20)
            make.width.equalTo(view.frame.size.width - 40)
            make.height.equalTo(50)
        }
        
        attachImagesLabel.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }
        
        attachImagesView.snp.makeConstraints { make in
            make.top.equalTo(attachImagesLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo((view.frame.size.width - MultiSetImagesView.Constants.itemSpaceForMultiItemsInPage * attachImagesView.numberOfItemInPage) / attachImagesView.numberOfItemInPage)
            make.bottom.equalToSuperview().offset(-356)
        }
    }
    
    // MARK: - Handlers
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
        for (i, image) in attachImagesView.images.enumerated() {
            mailComposeVC.addAttachmentData(image.jpegData(compressionQuality: CGFloat(1.0))!, mimeType: "image/jpeg", fileName:  "image\(i).jpeg")
        }
        
        mailComposeVC.setToRecipients(["s.ru5c55an.n@gmail.com"])
        mailComposeVC.setSubject("Message from DartyApp")
        mailComposeVC.setMessageBody(messageTextView.text, isHTML: false)
        return mailComposeVC
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ContactWithUsVC: MFMailComposeViewControllerDelegate {
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

// MARK: - MultiSetImagesViewDelegate
extension ContactWithUsVC: MultiSetImagesViewDelegate {
    func showFullscreen(_ agrume: Agrume) {
        agrume.show(from: self)
    }
    
    func showActionSheet(_ actionSheet: UIAlertController) {
        present(actionSheet, animated: true, completion: nil)
    }
    
    func dismissImagePicker() {
        dismiss(animated: true, completion: nil)
    }
    
    func showCamera(_ imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showImagePicker(_ imagePicker: PHPickerViewController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showError(_ error: String) {
        SPAlert.present(title: error, preset: .error)
    }
}

// MARK: - UIScrollViewDelegate
extension ContactWithUsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 200)
        let h = max(0, y)
        mailAnimationView.snp.updateConstraints { update in
            update.height.equalTo(h)
        }
    }
}
