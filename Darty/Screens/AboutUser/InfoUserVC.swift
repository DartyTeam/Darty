//
//  InfoUserVC.swift
//  Darty
//
//  Created by Руслан Садыков on 26.07.2021.
//

import UIKit
import SPAlert
import Agrume
import Hero
import SkeletonView

protocol AboutUserPartyRequestDelegate: AnyObject {
    func userDidDecline(_ user: UserModel)
    func userDidAccept(_ user: UserModel)
}

protocol AboutUserChatRequestDelegate: AnyObject {
    func userDidDecline(_ chat: RecentChatModel)
    func userDidAccept(_ chat: RecentChatModel, user: UserModel)
}

final class InfoUserVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let textColor: UIColor = .white
        static let nameFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .medium)
        static let ratingFont: UIFont? = .sfProRounded(ofSize: 20, weight: .semibold)
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .medium)
        
        static let descriptionTitleText = "Описание"
        static let descriptoonTextFont: UIFont? = .sfProText(ofSize: 12, weight: .regular)
        
        static let interestsTitleText = "Интересы"
        
        static let sectionInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        static let spacingInterest: CGFloat = 12
        
        static let arrowSize: CGFloat = 30
        
        static let messageTitleText = "Сообщение"
        static let messageTextFont: UIFont? = .sfProText(ofSize: 12, weight: .regular)
        
        static let instagramTitleLabelText = "Фото в Instagram"
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
        label.isSkeletonable = true
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.nameFont
        label.textColor = Constants.textColor
        label.isSkeletonable = true
        return label
    }()
    
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ratingFont
        label.textColor = Constants.textColor
        label.isSkeletonable = true
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
        label.isSkeletonable = true
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
        collectionView.isSkeletonable = true
        collectionView.prepareSkeleton { done in
            self.interestsCollectionView.showAnimatedGradientSkeleton()
        }
        return collectionView
    }()
    
    private let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    private let messageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        label.text = Constants.messageTitleText
        return label
    }()
    
    private let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.messageTextFont
        label.textColor = Constants.textColor
        label.numberOfLines = 0
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var acceptButton: DButton = {
        let button = DButton(title: "Принять")
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var declineButton: DButton = {
        let button = DButton(title: "Отклонить", type: .secondary)
        button.addTarget(self, action: #selector(declineAction), for: .touchUpInside)
        return button
    }()
    
    private let changeMyUserData: DButton = {
        let button = DButton(title: "Изменить данные")
        button.addTarget(self, action: #selector(changeAction), for: .touchUpInside)
        return button
    }()
    
    private let instagramTitleLable: UILabel = {
        let label = UILabel()
        label.text = Constants.instagramTitleLabelText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private let connectInstagramButton: DButton = {
        let button = DButton(title: "Подключить Instagram")
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(connectInstagram), for: .touchUpInside)
        return button
    }()
    
    private lazy var instagramPhotosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.register(InstagramPhotoCell.self, forCellWithReuseIdentifier: InstagramPhotoCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.isSkeletonable = true
        return collectionView
    }()
    
    // MARK: - Delegate
    var partyRequestDelegate: AboutUserPartyRequestDelegate?
    var chatRequestDelegate: AboutUserChatRequestDelegate?
    weak var coordinatorDelegate: AccountCoordinatorDelegate?
    
    // MARK: - Properties
    private var instagramApi = InstagramApi.shared
    private var instagramUser: InstagramUser?
    private var instagramPhotos: [InstaMediaData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.instagramPhotosCollectionView.reloadSections([0])
            }
        }
    }
    private var instagramPhotoUrls: [URL] = []
    private var userData: UserModel!
    private var type: AboutUserVCType
    private var message: String? = nil
    private var chatData: RecentChatModel?
    private var preloadedUserImage: UIImage?
    
    // MARK: - Init
    init(message: String) {
        self.type = .partyRequest
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    init(type: AboutUserVCType, preloadedUserImage: UIImage?) {
        self.type = type
        self.preloadedUserImage = preloadedUserImage
        super.init(nibName: nil, bundle: nil)
    }
    
    init(chatData: RecentChatModel) {
        self.type = .messageRequest
        self.chatData = chatData
        self.message = chatData.lastMessageContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addHideKeyboardOnTapAround()
        setupViews()
        setupConstraints()
        setupHero()
    }

    private func setupHero() {
        self.hero.isEnabled = true
        blurEffectView.hero.modifiers = [.translate(y: 600)]
        blurEffectView.contentView.hero.modifiers = blurEffectView.hero.modifiers
    }
    
    private func addHideKeyboardOnTapAround() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupWith(userData: UserModel) {
        self.userData = userData
        nameLabel.text = userData.username
        descriptionTextLabel.text = userData.description
        
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: userData.birthday, to: now)
        ageLabel.text = String(ageComponents.year!)
        
        userRatingLabel.text = "0.0 *"
        
        messageTextLabel.text = message
        
        print("asdjaiosdjasdoiaoisdjasiodasd: ", userData.instagramId)
        if let instagramId = userData.instagramId, UserDefaults.standard.instagramAccessToken != nil {
            scrollView.addSubview(instagramTitleLable)
            scrollView.addSubview(instagramPhotosCollectionView)
            scrollView.addSubview(connectInstagramButton)
            interestsCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(interestsTitleLable.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(54)
                make.width.equalTo(view.frame.size.width)
            }
            instagramTitleLable.snp.makeConstraints { make in
                make.top.equalTo(interestsCollectionView.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(26)
            }

            instagramPhotosCollectionView.snp.makeConstraints { make in
                make.top.equalTo(instagramTitleLable.snp.bottom).offset(16)
                make.left.right.equalToSuperview()
                make.height.equalTo(64)
            }

            connectInstagramButton.snp.makeConstraints { make in
                make.top.equalTo(instagramTitleLable.snp.bottom).offset(16)
                make.height.equalTo(44)
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().offset(-96)
            }
            connectInstagramButton.isHidden = true
            getInstaPhotos(with: instagramId)
        }
    }
    
    private func setupViews() {
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.contentView.addSubview(scrollView)

        scrollView.addSubview(arrowDirectionImageView)
        scrollView.addSubview(nameAgeStackView)
        scrollView.addSubview(userRatingLabel)
        scrollView.addSubview(descriptionTitleLabel)
        scrollView.addSubview(descriptionTextLabel)
        scrollView.addSubview(interestsTitleLable)
        scrollView.addSubview(interestsCollectionView)
        
        switch type {
        case .myInfo:
            scrollView.addSubview(changeMyUserData)
        case .info:
            scrollView.addSubview(messageTextField)
        case .partyRequest, .messageRequest:
            scrollView.addSubview(messageTitleLabel)
            scrollView.addSubview(messageTextLabel)
            scrollView.addSubview(acceptButton)
            scrollView.addSubview(declineButton)
        }
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
        
        switch type {
        case .myInfo:
            changeMyUserData.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(28)
                make.left.right.equalToSuperview().inset(22)
                make.height.equalTo(50)
            }
            
            descriptionTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(changeMyUserData.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(26)
            }
        case .info:
            messageTextField.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(28)
                make.left.right.equalToSuperview().inset(22)
                make.height.equalTo(48)
            }
            
            descriptionTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(messageTextField.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(26)
            }
        case .partyRequest, .messageRequest:
            messageTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(28)
                make.left.equalToSuperview().offset(26)
            }
            
            messageTextLabel.snp.makeConstraints { make in
                make.top.equalTo(messageTitleLabel.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(22)
            }
            
            declineButton.snp.makeConstraints { make in
                make.top.equalTo(messageTextLabel.snp.bottom).offset(24)
                make.height.equalTo(44)
                make.left.equalToSuperview().offset(22)
                make.width.equalTo(view.frame.size.width / 2.5)
            }
            
            acceptButton.snp.makeConstraints { make in
                make.top.equalTo(messageTextLabel.snp.bottom).offset(24)
                make.height.equalTo(44)
                make.right.equalToSuperview().inset(22)
                make.width.equalTo(view.frame.size.width / 2.5)
            }
            
            descriptionTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(declineButton.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(26)
            }
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
    @objc private func acceptAction() {
        startLoading()
        if type == .partyRequest {
            partyRequestDelegate?.userDidAccept(userData)
        } else if type == .messageRequest {
            guard let chatData = chatData else {
                print("ERROR_LOG Error retrieving optional chatData")
                stopLoading()
                return
            }
            chatRequestDelegate?.userDidAccept(chatData, user: userData)
        }
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func declineAction() {
        if type == .partyRequest {
            partyRequestDelegate?.userDidDecline(userData)
        } else if type == .messageRequest {
            guard let chatData = chatData else {
                print("ERROR_LOG Error retrieving optional chatData")
                return
            }
            chatRequestDelegate?.userDidDecline(chatData)
        }
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func shareAction() {
        #warning("Добавить функцию поделиться")
    }
    
    @objc private func changeAction() {
        coordinatorDelegate?.openChangeInfo(preloadedUserImage: preloadedUserImage, isNeedAnimatedShowImage: false)
    }
    
    @objc private func sendMessageAction() {
        guard let message = messageTextField.text, !message.isEmptyOrWhitespaceOrNewLines() else { return }
        startLoading()
        FirestoreService.shared.createWaitingChat(message: message, receiver: userData) { [weak self] (result) in
            switch result {
            case .success():
                guard let self = self else { return }
                SPAlert.present(title: "Ваше сообщение для \(self.userData.username) было отправлено", preset: .done)
                self.view.endEditing(true)
                self.messageTextField.text?.removeAll()
                self.stopLoading()
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
                self?.stopLoading()
            }
        }
    }
    
    @objc private func tapAction() {
        self.view.endEditing(true)
    }
    
    @objc private func connectInstagram() {
        let instaAuthVC = InstaAuthViewController(instagramApi: instagramApi)
        instaAuthVC.delegate = self
        present(instaAuthVC, animated:true)
    }
    
    @objc private func showFullImageAction(_ sender: UITapGestureRecognizer) {
        sender.view?.showAnimation { [weak self] in
            guard let self = self else { return }
                        
            let agrume = Agrume(
                urls: self.instagramPhotoUrls,
                startIndex: sender.view?.tag ?? 0
            )
            
            agrume.didScroll = { [unowned self] index in
                self.instagramPhotosCollectionView.scrollToItem(
                    at: IndexPath(item: index, section: 0),
                    at: [],
                    animated: false
                )
            }
            
            agrume.show(from: self)
        }
    }
    
    private func getInstaPhotos(with instagramId: String) {
        if let accessToken = UserDefaults.standard.instagramAccessToken {
            self.instagramApi.getMediaData(for: instagramId, accessToken: accessToken, completion: { [weak self] instagramMediaData in
                print("asdioajidaiosjdiasjoidjaisjoidas")
                if let error = instagramMediaData.error {
                    DispatchQueue.main.async {
                        self?.connectInstagramButton.isHidden = false
                        SPAlert.present(title: "Instagram: " + error.errorUserTitle, message: error.errorUserMsg, preset: .error)
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.connectInstagramButton.isHidden = true
                }
                if let instaPhotos = instagramMediaData.data?.sorted(by: { $0.timestamp > $1.timestamp }).filter({ instaMediaDataItem in
                    instaMediaDataItem.mediaType == .IMAGE
                }) {
                    self?.instagramPhotoUrls = instaPhotos.map({ instaMediaDataItem in
                        instaMediaDataItem.mediaUrl
                    })
                    self?.instagramPhotos = instaPhotos
                }
            })
        }
    }
}

// MARK: - InstaAuthDelegate
extension InfoUserVC: InstaAuthDelegate {
    func didGetUserData(_ instaUser: InstagramTestUser) {
        startLoading()
        instagramApi.getLongTermAccessTiken(accessToken: instaUser.accessToken) { [weak self] instaLongTermAccessToken in
            guard let self = self else { return }
            if let error = instaLongTermAccessToken.error {
                DispatchQueue.main.async {
                    self.stopLoading()
                    SPAlert.present(title: "Instagram: " + error.errorUserTitle, message: error.errorUserMsg, preset: .error)
                }
                return
            }
            self.instagramApi.getInstagramUser(testUserData: instaUser) { [weak self] (user) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.stopLoading()
                    SPAlert.present(title: "Вход выполнен с акканта:", message: user.username, preset: .done)
                }
                self.instagramUser = user
                UserDefaults.standard.instagramAccessToken = instaLongTermAccessToken.accessToken
                self.getInstaPhotos(with: self.userData.instagramId ?? "\(user.id)")
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension InfoUserVC: SkeletonCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == instagramPhotosCollectionView {
            return instagramPhotoUrls.count
        } else {
            return userData?.interestsList.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == instagramPhotosCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InstagramPhotoCell.reuseIdentifier,
                for: indexPath
            ) as! InstagramPhotoCell
            let photoUrl = instagramPhotoUrls[indexPath.row]
            cell.configure(with: photoUrl)
            cell.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullImageAction(_:)))
            cell.addGestureRecognizer(tapGestureRecognizer)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InterestCell.reuseIdentifier,
                for: indexPath
            ) as! InterestCell
            let interest = ConfigService.shared.interestsArray[userData.interestsList[indexPath.row]]
            cell.setupCell(title: interest.title, emoji: interest.emoji)
            if AuthService.shared.currentUser?.interestsList.contains(userData.interestsList[indexPath.row]) ?? false {
                cell.isSelected = true
            }
            return cell
        }
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if skeletonView == instagramPhotosCollectionView {
            return InstagramPhotoCell.reuseIdentifier
        } else {
            return InterestCell.reuseIdentifier
        }
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if skeletonView == instagramPhotosCollectionView {
            let cell = skeletonView.dequeueReusableCell(
                withReuseIdentifier: InstagramPhotoCell.reuseIdentifier,
                for: indexPath
            ) as! InstagramPhotoCell
            let photoUrl = instagramPhotoUrls[indexPath.row]
            cell.configure(with: photoUrl)
            cell.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullImageAction(_:)))
            cell.addGestureRecognizer(tapGestureRecognizer)
            return cell
        } else {
            let cell = skeletonView.dequeueReusableCell(
                withReuseIdentifier: InterestCell.reuseIdentifier,
                for: indexPath
            ) as! InterestCell
            cell.setupCell(title: "...", emoji: "Загрузка")
            return cell
        }
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension InfoUserVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.spacingInterest
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.spacingInterest
    }
}

// MARK: - UITextFieldDelegate
extension InfoUserVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
