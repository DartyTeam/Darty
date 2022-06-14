//
//  AboutSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit
import FirebaseAuth
import SPAlert

final class AboutSetupProfileVC: BaseController {

    // MARK: - UI Elements
    private lazy var nextButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var aboutTextView: TextView = {
        let textView = TextView(placeholder: "Описание вас", isEditable: true, color: .systemBlue)
        textView.delegate = self
        return textView
    }()

    // MARK: - Delegate
    weak var delegate: AboutSetupProfileDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "О вас"
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupViews() {
        if let image = UIImage(named: "about.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.75)) {
            addBackground(image)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(aboutTextView)
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        let descriptionText = aboutTextView.text
        guard !descriptionText.isEmptyOrWhitespaceOrNewLines() else {
            SPAlert.present(
                title: "Расскажите о себе",
                message: "Поле не может быть пустым",
                preset: .custom(UIImage(.text.bubble)),
                haptic: .error
            )
            return
        }
        delegate?.goNext(description: descriptionText)
    }
}

// MARK: - Setup constraints
extension AboutSetupProfileVC {
    private func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-44)
            make.height.equalTo(UIButton.defaultButtonHeight)
        }

        aboutTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(nextButton.snp.top).offset(-44)
            make.height.equalTo(256)
        }
    }
}

// MARK: - UITextViewDelegate
extension AboutSetupProfileVC: TextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {

    }

    func textViewDidChange(_ textView: UITextView) {
//        if let font = aboutTextView.font {
//            let maxChars = aboutTextView.frame.width / font.pointSize
//            let maxLines = aboutTextView.frame.height / font.lineHeight
//
//            let currentChars = aboutTextView.contentSize.width / font.pointSize
//            let currentLines = aboutTextView.contentSize.height / font.lineHeight
//
//            let currentValue = Int(currentChars) * Int(currentLines)
//            let maxValue = Int(maxLines) * Int(maxChars)
//            if currentValue >= maxValue {
//                textView.updateTextFont()
//            } else {
//                textView.centerVertically()
//            }
//        }
    }
}
