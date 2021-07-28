//
//  InfoUserVC.swift
//  Darty
//
//  Created by Руслан Садыков on 26.07.2021.
//

import UIKit
import SPAlert

final class InfoUserVC: UIViewController {
    
    private enum Constants {
        static let textColor: UIColor = .white
        static let nameFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .medium)
        static let ratingFont: UIFont? = .sfProRounded(ofSize: 20, weight: .semibold)
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .medium)
        
        static let descriptionTitleText = "Описание"
        static let descriptoonTextFont: UIFont? = .sfProText(ofSize: 12, weight: .regular)
        
        static let interestsTitleText = "Интересы"
        
        static let sectionInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0)
        
        static let arrowSize: CGFloat = 30
    }
    
    // MARK: - UI Elements
    let arrowDirectionImageView: ArrowView = {
        let arrow = ArrowView(frame: CGRect(x: 0, y: 0, width: Constants.arrowSize, height: Constants.arrowSize))
        arrow.arrowAnimationDuration = 0.3
        arrow.arrowColor = Constants.textColor
        arrow.update(to: .middle, animated: false)
        return arrow
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.nameFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.nameFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ratingFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private lazy var nameAgeStackView: UIStackView = {
        let spacingView = UIView()
        let stackView = UIStackView(arrangedSubviews: [nameLabel, ageLabel, spacingView], axis: .horizontal, spacing: 4)
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var messageTextField: MessageTextField = {
        let messageTextField = MessageTextField()
        messageTextField.color = .orangeYellow
        messageTextField.returnKeyType = .done
        messageTextField.delegate = self
        messageTextField.sendButton.addTarget(self, action: #selector(sendMessageAction), for: .touchDown)
        return messageTextField
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.descriptionTitleText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private let descriptionTextLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.descriptoonTextFont
        label.textColor = Constants.textColor
        label.numberOfLines = 0
        return label
    }()
    
    private let interestsTitleLable: UILabel = {
        let label = UILabel()
        label.text = Constants.interestsTitleText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private lazy var interestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.register(InterestCell.self, forCellWithReuseIdentifier: InterestCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        return collectionView
    }()
    
    private let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    // MARK: - Properties
    private var userData: UserModel
    private var type: AboutUserVCType
    
    // MARK: - Lifecycle
    init(userData: UserModel, type: AboutUserVCType) {
        self.userData = userData
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addHideKeyboardOnTapAround()
        setupUser()
        setupViews()
        setupConstraints()
    }
    
    private func addHideKeyboardOnTapAround() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    private func setupUser() {
        nameLabel.text = userData.username
        descriptionTextLabel.text = userData.description
        
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: userData.birthday, to: now)
        ageLabel.text = String(ageComponents.year!)
        
        userRatingLabel.text = "0.0 *"
    }
    
    private func setupViews() {
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.contentView.addSubview(arrowDirectionImageView)
        blurEffectView.contentView.addSubview(scrollView)
        scrollView.addSubview(messageTextField)
        scrollView.addSubview(nameAgeStackView)
        scrollView.addSubview(userRatingLabel)
        scrollView.addSubview(descriptionTitleLabel)
        scrollView.addSubview(descriptionTextLabel)
        scrollView.addSubview(interestsTitleLable)
        scrollView.addSubview(interestsCollectionView)
    }
    
    private func setupConstraints() {
        arrowDirectionImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(Constants.arrowSize)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        userRatingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.right.equalToSuperview().inset(26)
        }
        
        nameAgeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-76)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(48)
        }
        
        descriptionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(messageTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        descriptionTextLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(22)
        }
        
        interestsTitleLable.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        // Этот элемент растягивает scroll view по ширине
        interestsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(interestsTitleLable.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(54)
            make.width.equalTo(view.frame.size.width)
            make.bottom.equalToSuperview().offset(-96)
        }
    }
    
    // MARK: - Handlers
    @objc private func shareAction() {
        #warning("Добавить функцию поделиться")
    }
    
    @objc private func sendMessageAction() {
        guard let message = messageTextField.text, !message.isEmptyOrWhitespaceOrNewLines() else { return }
        
        FirestoreService.shared.createWaitingChat(message: message, receiver: userData) { [weak self] (result) in
            switch result {
            case .success():
                guard let self = self else { return }
                SPAlert.present(title: "Ваше сообщение для \(self.userData.username) было отправлено", preset: .done)
                self.view.endEditing(true)
                self.messageTextField.text?.removeAll()
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
            }
        }
    }
    
    @objc private func tapAction() {
        self.view.endEditing(true)
    }
}

extension InfoUserVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: UICollectionViewDataSource
extension InfoUserVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userData.interestsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestCell.reuseIdentifier, for: indexPath) as! InterestCell
        let interest = GlobalConstants.interestsArray[userData.interestsList[indexPath.row]]
    
        cell.setupCell(title: interest.title, emoji: interest.emoji)
        
        if AuthService.shared.currentUser?.interestsList.contains(userData.interestsList[indexPath.row]) ?? false {
            cell.isSelected = true
        }

        return cell
    }
}

extension InfoUserVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.sectionInsets.left
    }
}
