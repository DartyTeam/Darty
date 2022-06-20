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

final class ContactWithUsVC: BaseController {
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private let mailAnimationView = AnimationView(name: "SendMail")
    
    private let messageTextView: TextView = {
        let textView = TextView(placeholder: "Сообщение", isEditable: true)
        return textView
    }()
    
    private let sendButton: DButton = {
        let button = DButton(title: "Отправить")
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
        let multiSetImagesView = MultiSetImagesView(
            maxPhotos: 10,
            shape: .rect
        )
        multiSetImagesView.numberOfItemInPage = 3
        multiSetImagesView.delegate = self
        multiSetImagesView.isPagingEnabled = false
        return multiSetImagesView
    }()

    // MARK: - Properties
    private let mailAnimationTopOffset: CGFloat = 16
    private let mailAnimationHeight: CGFloat = 300
    private let mailAndScrollViewSpacing: CGFloat = 64
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Обратная связь"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardAction))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        setupViews()
        setupConstraints()
    }

    private var savedScrollViewContentInsets: UIEdgeInsets = .zero

    @objc private func keyboardWillHide(notification: NSNotification) {
        print("saoidjasjiodiojasoijasdoijasiojoijasdoijasiojdoijasoida")
        scrollView.contentInset = savedScrollViewContentInsets
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        scrollView.scrollRectToVisible(.zero, animated: true)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    @objc private func keyboardWillAppear(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        let keyboardBottomOffset: CGFloat = 32
        savedScrollViewContentInsets = scrollView.contentInset
        scrollView.contentInset = UIEdgeInsets(
            top: mailAnimationHeight + mailAnimationTopOffset + mailAndScrollViewSpacing,
            left: 0,
            bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyboardBottomOffset,
            right: 0
        )
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        scrollView.scrollRectToVisible(CGRect(
            origin: sendButton.frame.origin,
            size: CGSize(
                width: sendButton.frame.size.width,
                height: sendButton.frame.size.height + keyboardBottomOffset
            )
        ), animated: true)
        scrollView.contentSize = CGSize(
            width: view.frame.size.width,
            height: scrollView.frame.size.height - scrollView.contentInset.bottom
        )
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mailAnimationView.play()
        }
    }

    // MARK: - Setup
    private func setupViews() {
        mailAnimationView.contentMode = .scaleAspectFit
        view.addSubview(mailAnimationView)
        view.addSubview(scrollView)
        scrollView.addSubview(messageTextView)
        scrollView.addSubview(sendButton)
        scrollView.addSubview(attachImagesLabel)
        scrollView.addSubview(attachImagesView)
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
        for (i, imageItem) in attachImagesView.images.enumerated() {
            mailComposeVC.addAttachmentData(
                imageItem.image.jpegData(compressionQuality: CGFloat(1.0))!,
                mimeType: "image/jpeg",
                fileName:  "image\(i).jpeg"
            )
        }
        mailComposeVC.setToRecipients(["s.ru5c55an.n@gmail.com"])
        mailComposeVC.setSubject("Message from DartyApp")
        mailComposeVC.setMessageBody(messageTextView.text, isHTML: false)
        return mailComposeVC
    }

    @objc private func hideKeyboardAction() {
        view.endEditing(true)
    }
}

// MARK: - Setup constraints
extension ContactWithUsVC {
    private func setupConstraints() {
        mailAnimationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.right.equalToSuperview().inset(64)
            make.height.equalTo(mailAnimationHeight)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.contentInset = UIEdgeInsets(
            top: mailAnimationHeight + mailAnimationTopOffset + mailAndScrollViewSpacing,
            left: 0,
            bottom: 100,
            right: 0
        )
        scrollView.verticalScrollIndicatorInsets = scrollView.contentInset

        messageTextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(128)
        }

        sendButton.snp.makeConstraints { make in
            make.top.equalTo(messageTextView.snp.bottom).offset(44)
            make.left.right.equalToSuperview().inset(24)
            make.width.equalTo(view.frame.size.width - 48)
            make.height.equalTo(DButtonStyle.fill.height)
        }

        attachImagesLabel.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }

        attachImagesView.snp.makeConstraints { make in
            make.top.equalTo(attachImagesLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(
                (
                    view.frame.size.width -
                    MultiSetImagesView.Constants.itemSpaceForMultiItemsInPage * attachImagesView.numberOfItemInPage
                )
                / attachImagesView.numberOfItemInPage
            )
            make.bottom.equalToSuperview()
        }
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

    func showAlertController(_ alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
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
        let y = 400 - scrollView.contentInset.top - (scrollView.contentOffset.y + 200)
        let h = max(0, y)
        mailAnimationView.snp.updateConstraints { update in
            update.height.equalTo(h)
        }
    }
}
