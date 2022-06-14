//
//  NameSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import UIKit
import FirebaseAuth
import SPAlert

final class NameSetupProfileVC: BaseController {

    // MARK: - Constraints
    private enum Constants {
        static let textPlaceholder = "Введите имя..."
        static let textFont: UIFont? = .sfProText(ofSize: 24, weight: .medium)
        static let maxIllustrationHeight: CGFloat = 544
    }
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    private let illustrationImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "whatName"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var nextButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: BottomLineTextField = {
        let textField = BottomLineTextField(color: .systemBlue)
        textField.placeholder = Constants.textPlaceholder
        textField.font = Constants.textFont
        textField.textAlignment = .center
        textField.delegate = self
        textField.returnKeyType = .next
        return textField
    }()

    // MARK: - Delegate
    weak var delegate: NameSetupProfileDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Имя"
        setupKeyboardLogic()
        setupViews()
    }

    private func setupKeyboardLogic() {
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard nextButton.constraints.isEmpty else { return }
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(illustrationImageView)
        scrollView.addSubview(nameTextField)
        view.addSubview(bottomView)
        bottomView.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    @objc private func keyboardWillAppear(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        let keyboardBottomOffset: CGFloat = 64
        print("aisojdioajsdioajsmdiajodmaiosjdasd: ", keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyboardBottomOffset)
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + keyboardBottomOffset,
            right: 0
        )
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        scrollView.scrollRectToVisible(nextButton.frame, animated: true)
        scrollView.contentSize = CGSize(
            width: view.frame.size.width,
            height: scrollView.frame.size.height - scrollView.contentInset.bottom
        )
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboardAction()
    }

    @objc private func hideKeyboardAction() {
        view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        guard let username = nameTextField.text, !username.isEmptyOrWhitespaceOrNewLines() else {
            SPAlert.present(title: "Необходимо ввести имя", preset: .custom(UIImage(.textformat)), haptic: .error)
            return
        }
        delegate?.goNext(name: username)
    }
}

// MARK: - Setup constraints
extension NameSetupProfileVC {
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        scrollView.contentSize = scrollView.frame.size

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        let nextButtonBottomOffset: CGFloat = 44
        let nextButtonHeight = UIButton.defaultButtonHeight
        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(nextButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-nextButtonBottomOffset)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.frame.size.height -
                                               view.safeAreaInsets.top -
                                               view.safeAreaInsets.bottom -
                                               nextButtonHeight -
                                               nextButtonBottomOffset -
                                               112)
            make.width.equalToSuperview().inset(44)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        illustrationImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.width.equalToSuperview().inset(44)
            make.centerX.equalToSuperview().offset(10)
            make.height.equalTo(Constants.maxIllustrationHeight)
        }
    }
}

// MARK: - UITextFieldDelegate
extension NameSetupProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextButtonTapped()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.select(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextField.select(false)
    }
}

// MARK: - UIScrollViewDelegate
extension NameSetupProfileVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defauiltIllustrationRemovedHeight: CGFloat = 100
        let y = Constants.maxIllustrationHeight - (scrollView.contentOffset.y + defauiltIllustrationRemovedHeight)
        let h = max(0, y)
        illustrationImageView.snp.updateConstraints { update in
            update.height.equalTo(h)
        }
    }
}
