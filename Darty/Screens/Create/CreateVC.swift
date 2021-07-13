//
//  CreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseAuth
import SnapKit

struct SetuppedParty {
    var name: String?
    var description: String?
    var city: String?
    var location: String?
    var userId: String?
    var maximumPeople: Int?
    var currentPeople: Int?
    var date: Date?
    var startTime: Date?
    var endTime: Date?
    var priceType: String?
    var price: Int?
    var images: UIImage?
    var minAge: Int?
    var type: PartyType?
}

final class CreateVC: UIViewController {
    
    private enum Constants {
        static let textPlaceholder = "Наименование"
        static let textFont: UIFont? = .sfProText(ofSize: 12, weight: .regular)
    }
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
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
    
    private lazy var nameTextField: TextField = {
        let textField = TextField(color: .systemPurple, placeholder: Constants.textPlaceholder)
        textField.font = Constants.textFont
        textField.delegate = self
        textField.returnKeyType = .next
        return textField
    }()
    
    private let aboutTextView: TextView = {
        let textView = TextView(isEditable: true, color: .systemPurple)
        return textView
    }()
    
    // MARK: - Properties
    private let currentUser: UserModel
    private var party: PartyModel?
    
    // MARK: - Lifecycle
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        setupViews()
        setupConstraints()
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
           contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
        
        scrollView.scrollRectToVisible(aboutTextView.frame, animated: true)

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func tapAction() {
        view.endEditing(true)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(aboutTextView)
        scrollView.addSubview(logoView)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            nameTextField.setError(message: "Название не может быть пустым")
            
            if aboutTextView.text.isEmpty {
                aboutTextView.setError(message: "Описание не может быть пустым")
            }
            
            return
        }
        
        let about = aboutTextView.text
        guard !about.isEmpty else {
            aboutTextView.setError(message: "Описание не может быть пустым")
            return
        }
        
        let setuppedParty = SetuppedParty(name: name, description: about)
        let secondCreateVC = SecondCreateVC(currentUser: currentUser, setuppedParty: setuppedParty)
        secondCreateVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(secondCreateVC, animated: true)
    }
}

// MARK: - Setup constraints
extension CreateVC {
    
    private func setupConstraints() {
                
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.centerX.equalToSuperview()
        }
        
        var topSafeAreaHeight: CGFloat = 0
        var bottomSafeAreaHeight: CGFloat = 0
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        topSafeAreaHeight = safeFrame.minY
        bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        
        print("asdiojasdioajsdioasjdi: ", topSafeAreaHeight, bottomSafeAreaHeight, GlobalConstants.tabBarHeight, navigationController!.navigationBar.frame.size.height)
        
        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.frame.size.height - topSafeAreaHeight - bottomSafeAreaHeight - GlobalConstants.tabBarHeight - navigationController!.navigationBar.frame.size.height - (32 * 2 + 16))
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        aboutTextView.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(144)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(aboutTextView.snp.top).offset(-32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.width.equalToSuperview().inset(20)
        }
    }
}

extension CreateVC: UITextFieldDelegate {
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        aboutTextView.becomeFirstResponder()
        return false
    }
}
