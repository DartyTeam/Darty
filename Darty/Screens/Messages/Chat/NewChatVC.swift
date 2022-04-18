//
//  NewChatVC.swift
//  Darty
//
//  Created by Руслан Садыков on 05.08.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import RealmSwift
import AVFoundation
import PhotosUI
import SPAlert
    
class NewChatVC: MessagesViewController {

    // MARK: - Constants
    private enum Constants {
        static let inputBarButtonsSize: CGSize = CGSize(width: 48, height: 48)
        static let numberOfMessages = 12
        static let maxPhotosForChoose = 5
        static let avatarSize = CGSize(width: 34, height: 34)

        static let messagePlaceholder = "Сообщение..."
        static let sendingMessageInProccessPlaceholder = "Отправка..."
        static let messagePlaceholderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        static let boldIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .medium))

        static let recordButtonSpace: CGFloat = 100
        static let deleteButtonSpace: CGFloat = 200
        static let rightRecordButtonPadding: CGFloat = 44

        static let writingText = "Печатает..."
    }
    
    // MARK: - UI Elements
    private let refreshController: UIRefreshControl = {
        let refreshController = UIRefreshControl()
        return refreshController
    }()
    
    private lazy var micButton: InputBarButtonItem = {
        let inputBarButtonItem = InputBarButtonItem(type: .system)
        inputBarButtonItem.image = UIImage(systemName: "mic")
        inputBarButtonItem.addGestureRecognizer(micLongPressGesture)
        inputBarButtonItem.tintColor = .systemTeal
        inputBarButtonItem.setSize(Constants.inputBarButtonsSize, animated: false)
        return inputBarButtonItem
    }()
    
    private let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(
            x: 5,
            y: 3,
            width: Constants.avatarSize.width,
            height: Constants.avatarSize.height
        ))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openRecipientAccountInfo))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.avatarSize.height / 2
        imageView.hero.id = GlobalConstants.userImageHeroId
        imageView.isSkeletonable = true
        imageView.isUserInteractionDisabledWhenSkeletonIsActive = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 48, y: 0, width: UIScreen.main.bounds.size.width - 48 - 176, height: 25))
        label.textAlignment = .left
        label.font = UIFont.sfProRounded(ofSize: 16, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.isSkeletonable = true
        label.skeletonCornerRadius = 12
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 48, y: 22, width: 140, height: 20))
        label.textAlignment = .left
        label.font = UIFont.sfProRounded(ofSize: 12, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var configuration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = Constants.maxPhotosForChoose
        return configuration
    }()
    
    private lazy var imagePicker: PHPickerViewController = {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()

    private let callBarButtonItem: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        button.setImage(
            UIImage(
                systemName: "phone",
                withConfiguration: Constants.boldIconConfig)?
                .withTintColor(
                    .systemTeal,
                    renderingMode: .alwaysOriginal
                ),
            for: UIControl.State()
        )
        button.addTarget(self, action: #selector(callAction), for: .touchUpInside)
        button.alpha = 0
        return UIBarButtonItem(customView: button)
    }()

    private let facetimeBarButtonItem: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        button.setImage(
            UIImage(
                systemName: "video",
                withConfiguration: Constants.boldIconConfig)?
                .withTintColor(
                    .systemTeal,
                    renderingMode: .alwaysOriginal
                ),
            for: UIControl.State()
        )
        button.addTarget(self, action: #selector(facetimeAction), for: .touchUpInside)
        button.alpha = 0
        return UIBarButtonItem(customView: button)
    }()

    private lazy var audioRecordView = AudioRecordView(effect: messageInputBar.blurView.effect, cancelTappableViewRightInset: Constants.recordButtonSpace)
    private let audioRecordButton = AudioRecordButton()
        
    // MARK: - Listeners
    var notificationToken: NotificationToken?
    
    // MARK: - Properties
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    private let realm = try! Realm()
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    private var recipientData: UserModel?
    private let chatId: String
    private let recipientId: String
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: AuthService.shared.currentUser!.id, displayName: AuthService.shared.currentUser!.username)
    
    lazy var micLongPressGesture: UILongPressGestureRecognizer = {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio(gesture:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        return longPressGestureRecognizer
    }()
    
    var audioFileName: String = ""
    var audioDuration: Date!
    
    // MARK: - Inits
    init(chatId: String, recipientId: String) {
        self.chatId = chatId
        self.recipientId = recipientId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setIsTabBarHidden(true)
        startSkeleton()
        getRecipientData()
        createTypingObserver()
        configureMessageCollectionView()
        configureMessageInputBar()
        configureLeftBarButton()
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
    }
    
    deinit {
        removeListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        FirestoreService.shared.resetRecentCounter(chatRoomId: chatId) { result in
            switch result {
            case .success(_):
                print("Succesfull reset recent counter")
            case .failure(let error):
                print("ERROR_LOG Error reset recent counter: ", error.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirestoreService.shared.resetRecentCounter(chatRoomId: chatId) { result in
            switch result {
            case .success(_):
                print("Succesfull reset recent counter")
            case .failure(let error):
                print("ERROR_LOG Error reset recent counter: ", error.localizedDescription)
            }
        }
        audioController.stopAnyOngoingPlaying()
    }

    private func getRecipientData() {
        FirestoreService.shared.getUser(by: recipientId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let recipientData):
                DispatchQueue.main.async {
                    self.recipientData = recipientData
                    self.titleLabel.text = recipientData.username
                    self.titleLabel.hideSkeleton()
                    self.avatarImageView.setImage(stringUrl: recipientData.avatarStringURL)
                    UIView.animate(withDuration: 0.3) {
                        self.callBarButtonItem.customView?.alpha = 1
                        self.facetimeBarButtonItem.customView?.alpha = 1
                    }
                }
            case .failure(let error):
                print("ERROR_LOG Eror get user data with id \(self.recipientId): ", error.localizedDescription)
                SPAlert.present(title: "Не удалось получить данные собеседника", preset: .error)
                self.avatarImageView.hideSkeleton()
                self.titleLabel.hideSkeleton()
            }
        }
    }

    private func startSkeleton() {
        avatarImageView.showAnimatedGradientSkeleton()
        titleLabel.showAnimatedGradientSkeleton()
    }
    
    // MARK: - Configurations
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            let bottomLabelTopOffset: CGFloat = 2
            let bottomLabelHorizontalOffset: CGFloat = 4
            let incomingLabelAlignment = LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(
                    top: bottomLabelTopOffset,
                    left: bottomLabelHorizontalOffset,
                    bottom: 0,
                    right: 0
                )
            )
            let outgoindLabelAlignment = LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(
                    top: bottomLabelTopOffset,
                    left: 0,
                    bottom: 0,
                    right: bottomLabelHorizontalOffset
                )
            )
            layout.setMessageIncomingMessageBottomLabelAlignment(incomingLabelAlignment)
            layout.setMessageOutgoingMessageBottomLabelAlignment(outgoindLabelAlignment)
            layout.setMessageIncomingCellBottomLabelAlignment(incomingLabelAlignment)
            layout.setMessageOutgoingCellBottomLabelAlignment(outgoindLabelAlignment)
        }
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        updateMicButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .clear
        messageInputBar.backgroundColor = .clear
        
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.placeholderTextColor = Constants.messagePlaceholderColor
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 16, left: 44, bottom: 16, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 12)
        messageInputBar.inputTextView.layer.borderColor = UIColor.systemTeal.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1
        messageInputBar.inputTextView.layer.cornerRadius = 24.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        messageInputBar.inputTextView.placeholder = Constants.messagePlaceholder
        messageInputBar.inputTextView.font = .sfProDisplay(ofSize: 14, weight: .medium)
//        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        messageInputBar.layer.shadowRadius = 5
//        messageInputBar.layer.shadowOpacity = 0.3
//        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        configureSendButton()
        configureAttachButton()
    }

    private func configureAudioRecordView() {
        if !view.contains(audioRecordView) {
            view.addSubview(audioRecordView)
            audioRecordView.snp.makeConstraints { make in
                make.height.equalTo(messageInputBar.calculateIntrinsicContentSize().height + view.safeAreaInsets.bottom)
                make.left.right.bottom.equalToSuperview()
            }
            audioRecordView.isUserInteractionEnabled = false
            audioRecordView.delegate = self
            audioRecordButton.delegate = self
        }
        audioRecordView.isHidden = false
    }
    
    func configureAttachButton() {
        let attachButton = InputBarButtonItem(type: .system)
        attachButton.tintColor = .systemTeal
        let attachButtonImage = UIImage(systemName: "paperclip")!
        attachButton.image = attachButtonImage
        attachButton.setSize(Constants.inputBarButtonsSize, animated: false)
        attachButton.addTarget(self, action: #selector(actionAttachMessage),
                               for: .primaryActionTriggered)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.middleContentViewPadding.left = -66
        messageInputBar.setLeftStackViewWidthConstant(to: 76, animated: false)
    }
    
    func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "paperplane"), for: UIControl.State())
        messageInputBar.sendButton.setSize(Constants.inputBarButtonsSize, animated: false)
        messageInputBar.sendButton.title = nil
        messageInputBar.middleContentViewPadding.right = -66
        messageInputBar.setRightStackViewWidthConstant(to: 76, animated: false)
    }
    
    func updateMicButtonStatus(show: Bool) {
        messageInputBar.setStackViewItems([show ? micButton : messageInputBar.sendButton], forStack: .right, animated: false)
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))]
    }
        
    private func configureNavBar() {
        setNavigationBar(withColor: .systemTeal, title: nil, withClear: false)
        let attrs = [
            NSAttributedString.Key.font: UIFont.sfProRounded(ofSize: 16, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = attrs as [NSAttributedString.Key : Any]
        navigationItem.setRightBarButtonItems([facetimeBarButtonItem, callBarButtonItem], animated: true)
        configureCustomTitle()
    }
    
    private func configureCustomTitle() {
        guard !leftBarButtonView.contains(titleLabel) else { return }
        leftBarButtonView.addSubview(avatarImageView)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
    }
    
    @objc private func openRecipientAccountInfo() {
        guard let recipientData = recipientData else { return }
        let aboutUserVC = AboutUserVC(userData: recipientData, preloadedUserImage: avatarImageView.image)
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .none
        navigationController?.pushViewController(aboutUserVC, animated: true)
    }
    
    // MARK: - Load chats
    private func loadChats() {
        let predicate = NSPredicate(format: "\(GlobalConstants.kCHATROOMID) = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: GlobalConstants.kDATE, ascending: true)
        
        
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ [weak self] ( changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                self?.insertMessages()
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(animated: false)
            case .update(_, _, let insertions, _):
                self?.updateTypingIndicator(true, performUpdates: {
                    print("asidasiodjasiodijaosjdoiajosidjoias")
                })
                for index in insertions {
                    let isLastSectionVisible = self?.isLastSectionVisible()
                    if let localMessage = self?.allLocalMessages[index] {
                        self?.insertMessage(localMessage)
                    }
                    self?.messagesCollectionView.reloadData()
                    if isLastSectionVisible == true {
                        self?.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                }
            case .error(let error):
                print("ERROR_LOG Error on new insertion ", error.localizedDescription)
            }
        })
    }
    
    private func listenForNewChats() {
        ListenerService.shared.listenForNewChats(AuthService.shared.currentUser!.id, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
        FirestoreService.shared.checkForOldChats(AuthService.shared.currentUser!.id, collectionId: chatId)
    }
    
    // MARK: - Insert Messages
    private func listenForReadStatusChange() {
        ListenerService.shared.listenForReadStatusChange(AuthService.shared.currentUser!.id, collectionId: chatId) { [weak self] updatedMessage in
            if updatedMessage.status != GlobalConstants.kSENT {
                self?.updateMessage(updatedMessage)
            }
        }
    }
   
    private func insertMessages() {
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - Constants.numberOfMessages
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        if localMessage.senderId != AuthService.shared.currentUser?.id {
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self)
        if let mkMessage = incoming.createMessage(localMessage: localMessage) {
            self.mkMessages.append(mkMessage)
            displayingMessagesCount += 1
        } else {
            print("ERROR_LOG Cannot convert local message: \(localMessage) to MKMessage")
        }
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - Constants.numberOfMessages
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
        }
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        if let mkMessage = incoming.createMessage(localMessage: localMessage) {
            self.mkMessages.insert(mkMessage, at: 0)
            displayingMessagesCount += 1
        } else {
            print("ERROR_LOG Cannot convert local message: \(localMessage) to MKMessage")
        }
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != AuthService.shared.currentUser!.id && localMessage.status != GlobalConstants.kREAD {
            FirestoreService.shared.updateMessageInFirebase(localMessage, memberIds: [AuthService.shared.currentUser!.id, recipientId])
        }
    }
    
    // MARK: - Actions
    func messageSend(
        text: String?,
        photo: UIImage?,
        video: URL?,
        audio: String?,
        location: Location?,
        audioDuration: Float = 0.0) {
        messageInputBar.sendButton.startAnimating()
        updateMicButtonStatus(show: false)
        messageInputBar.inputTextView.placeholder = Constants.sendingMessageInProccessPlaceholder
        OutgoingMessage.send(
            chatId: chatId,
            text: text,
            photo: photo,
            video: video,
            audio: audio,
            audioDuration: audioDuration,
            location: location,
            memberIds: [AuthService.shared.currentUser!.id, recipientId]
        ) { [weak self] result in
            switch result {
            case .success():
                self?.updateInputBarAfterMessageSend()
            case .failure(_):
                self?.updateInputBarAfterMessageSend()
            }
        }
    }

    private func updateInputBarAfterMessageSend() {
        messageInputBar.sendButton.stopAnimating()
        messageInputBar.inputTextView.placeholder = Constants.messagePlaceholder
        updateMicButtonStatus(show: true)
    }
    
    @objc private func callAction() {
        guard let recipientData = recipientData else {
            print("ERROR_LOG Error unwrap recipientData")
            return
        }
        if let phoneUrl = URL(string: "tel://\(recipientData.phone)") {
            let application = UIApplication.shared
            if (application.canOpenURL(phoneUrl)) {
                UIApplication.shared.open(phoneUrl)
            } else {
                SPAlert.present(title: "Невозможно выполнить звонок", preset: .error)
                print("ERROR_LOG Error make phone call for phone number: ", recipientData.phone)
            }
        } else {
            SPAlert.present(
                title: "Невозможно выполнить звонок",
                message: "Возможно номер пользователя недействителен",
                preset: .error
            )
            print("ERROR_LOG Error get url from phone number: ", recipientData.phone)
        }
    }
    
    @objc private func facetimeAction() {
        guard let recipientData = recipientData else {
            print("ERROR_LOG Error unwrap recipientData")
            return
        }
        if let facetimeUrl = URL(string: "facetime://\(recipientData.phone)") {
            let application = UIApplication.shared
            if (application.canOpenURL(facetimeUrl)) {
                application.open(facetimeUrl)
            } else {
                SPAlert.present(title: "Невозможно выполнить звонок", preset: .error)
                print("ERROR_LOG Error make facetime call for phone number: ", recipientData.phone)
            }
        } else {
            SPAlert.present(
                title: "Невозможно выполнить звонок",
                message: "Возможно номер пользователя недействителен",
                preset: .error
            )
            print("ERROR_LOG Error get url from phone number: ", recipientData.phone)
        }
    }
    
    @objc private func backButtonPressed() {
        // TODO: remove listeners
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func actionAttachMessage() {
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.view.tintColor = .systemTeal
        let takePhotoOrVideo = UIAlertAction(title: "Камера", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        
        let shareMedia = UIAlertAction(title: "Библиотека", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }
        
        let shareLocation = UIAlertAction(title: "Местоположение", style: .default) { _ in
            let alert = UIAlertController(style: .actionSheet)
            alert.addLocationPicker { location in
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: location)
            }
            alert.addAction(title: "Cancel", style: .cancel)
            alert.show()
        }
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - Audio messages
    @objc private func recordAudio(gesture: UIGestureRecognizer) {
        var yPos = view.frame.size.height - (audioRecordView.frame.size.height / 2) - (audioRecordButton.frame.size.height / 4)
        let location = gesture.location(in: view)
        switch gesture.state {
        case .began:
            audioRecordView.setSwipeToCancel()
            audioRecordView.startInfoLabelAnimation()
            configureAudioRecordView()
            vibrate()
            audioDuration = Date()
            audioFileName = DateFormatter.ddMMyyyyHHmmss.string(from: Date())
            AudioRecorder.shared.startRecording(fileName: audioFileName)
            let messageViewHeight = messageInputBar.calculateIntrinsicContentSize().height + view.safeAreaInsets.bottom
            yPos = view.frame.size.height - (messageViewHeight / 2) - (audioRecordButton.frame.size.height / 3)
            audioRecordButton.update(center: CGPoint(x: location.x, y: yPos), state: .record)
            messageInputBar.isHidden = true
            view.addSubview(audioRecordButton)
        case .changed:
            let rightSpace = UIScreen.main.bounds.width - location.x
            let maxRightPosX = view.frame.size.width - Constants.rightRecordButtonPadding
            let isInSafeRightPadding = location.x >= maxRightPosX
            let xPos = isInSafeRightPadding ? maxRightPosX : location.x
            let bottomSpace = view.frame.size.height - location.y
            let yPosForStartStayRecord = audioRecordView.frame.size.height + audioRecordButton.frame.size.height
            switch bottomSpace {
            case yPosForStartStayRecord...view.frame.size.height:
                gesture.state = .cancelled
                audioRecordView.setTapToCancel()
                audioRecordButton.update(center: CGPoint(x: maxRightPosX, y: yPos), state: .stayRecord)
            default:
                switch rightSpace {
                case 0...Constants.recordButtonSpace:
                    audioRecordView.setSwipeToCancel()
                    audioRecordButton.update(center: CGPoint(x: xPos, y: location.y), state: .record)
                case Constants.recordButtonSpace...Constants.deleteButtonSpace:
                    audioRecordView.slideInfoLabel(offset: xPos)
                    audioRecordButton.update(center: CGPoint(x: xPos, y: location.y), state: .delete)
                default:
                    audioRecordButton.update(center: CGPoint(x: xPos, y: location.y), state: .end) { [weak self] in
                        gesture.state = .cancelled
                        self?.cancelRecordAudio()
                    }
                }
            }
        case .ended:
            audioRecordButton.update(center: CGPoint(x: location.x, y: yPos), state: .end) { [weak self] in
                gesture.state = .cancelled
                self?.endRecordAudio()
            }
        default:
            break
        }
    }

    private func endRecordAudio() {
        vibrate()
        audioRecordView.isHidden = true
        messageInputBar.isHidden = false
        AudioRecorder.shared.finishRecording()
        let path = audioFileName + ".m4a"
        if fileExistsAt(path: path) {
            let audioD = audioDuration.interval(comp: .second, fromDate: Date())
            messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
        } else {
            SPAlert.present(message: "Не удалось отправить аудиосообщение", haptic: .error)
            print("no audio file for send in message by path: ", path)
        }
        audioFileName.removeAll()
    }

    private func cancelRecordAudio() {
        vibrate()
        audioRecordView.isHidden = true
        messageInputBar.isHidden = false
        AudioRecorder.shared.finishRecording()
        let path = audioFileName + ".m4a"
        if fileExistsAt(path: path) {
            deleteFileAt(path: path)
        } else {
            print("no audio file for deleting by path: ", path)
        }
        audioFileName.removeAll()
    }

    private func vibrate() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    // MARK: - Update typing indicator
    func createTypingObserver() {
        ListenerService.shared.createTypingObserver(chatRoomId: chatId) { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.updateTypingIndicator(!isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        typingCounter += 1
        print("test......")
        ListenerService.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            ListenerService.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(show, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
        subtitleLabel.text = !show ? Constants.writingText : ""
    }
    
    func isLastSectionVisible() -> Bool {
        guard !mkMessages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: mkMessages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }
    
    // MARK: - Update read message status
    private func updateMessage(_ localMessage: LocalMessage) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            
            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                
                RealmManager.shared.saveToRealm(localMessage)
                
                if mkMessages[index].status == GlobalConstants.kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Helpers
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < mkMessages.count else { return false }
        return mkMessages[indexPath.section].sender.senderId == mkMessages[indexPath.section + 1].sender.senderId
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return mkMessages[indexPath.section].sender.senderId == mkMessages[indexPath.section - 1].sender.senderId
    }
    
    private func removeListeners() {
        ListenerService.shared.removeTypingListener()
        ListenerService.shared.removeChatListeners()
    }
    
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    // MARK: - Select photos
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if source == .camera {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
                if response {
                    if UIImagePickerController.isSourceTypeAvailable(source) {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.allowsEditing = true
                        imagePicker.sourceType = source
                        self?.present(imagePicker, animated: true, completion: nil)
                    }
                } else {
                    let alertController = UIAlertController(style: .alert, title: "Нет доступа к камере", message: "Необходимо пройти в настройки и включить доступ")
                    let settingsAction = UIAlertAction(title: "Перейти в настройки", style: .default) { _ in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self?.present(alertController, animated: true)
                    }
                }
            }
        } else {
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension NewChatVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        
        var images: [UIImage] = []
        
        for (i, item) in results.enumerated() {
            if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async { [weak self] in
                        if let image = image as? UIImage {
                            images.append(image)
                            self?.updateMicButtonStatus(show: false)
                            self?.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
                            if i == results.count - 1 {
                                print("Succesfull sended \(images.count) photos")
                            }
                        }
                    }
                }
            } else if item.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                item.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, err in
                    if let url = url {
                        DispatchQueue.main.sync { [weak self] in
                            self?.updateMicButtonStatus(show: false)
                            self?.messageSend(text: nil, photo: nil, video: url, audio: nil, location: nil)
                        }
                    }
                }
            } else {
                SPAlert.present(title: "Не удалось получить файл из галереи", preset: .error)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            updateMicButtonStatus(show: false)
            messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
        } else {
            SPAlert.present(title: "Ошибка получени изображения с камеры", preset: .error)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension NewChatVC: AudioRecordViewDelegate {
    func cancelTapped() {
        cancelRecordAudio()
        audioRecordButton.update(center: .zero, state: .end)
    }
}

extension NewChatVC: AudioRecordButtonDelegate {
    func sendButtonTapped() {
        endRecordAudio()
        audioRecordButton.update(center: .zero, state: .end)
    }
}
