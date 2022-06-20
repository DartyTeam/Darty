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

enum MessageDefaults {
    static let bubbleColorOutgoig = Colors.Elements.secondaryElement
    static let bubbleColorIncoming = Colors.Backgorunds.plate
    static let messageTimeLabelOffset: CGFloat = 8
}
    
class NewChatVC: MessagesViewController {

    // MARK: - Constants
    private enum Constants {
        static let inputBarButtonsSize: CGSize = CGSize(width: 48, height: 48)
        static let numberOfMessages = 12
        static let maxPhotosForChoose = 5
        static let avatarSize: CGFloat = 34

        static let messagePlaceholder = "Сообщение..."
        static let sendingMessageInProccessPlaceholder = "Отправка..."

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
        let micImage = UIImage(.mic).withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(
            ofSize: ButtonSymbolType.small.size,
            weight: ButtonSymbolType.small.weight
        )))
        inputBarButtonItem.image = micImage
        inputBarButtonItem.addGestureRecognizer(micLongPressGesture)
        inputBarButtonItem.addGestureRecognizer(micUpSwipeGesure)
        inputBarButtonItem.tintColor = Colors.Elements.element
        inputBarButtonItem.setSize(Constants.inputBarButtonsSize, animated: false)
        return inputBarButtonItem
    }()

    private let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.avatarSize / 2
        imageView.isSkeletonable = true
        imageView.isUserInteractionDisabledWhenSkeletonIsActive = true
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openRecipientAccountInfo))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Text.main
        label.font = .title
        label.adjustsFontSizeToFitWidth = true
        label.isSkeletonable = true
        label.skeletonCornerRadius = 12
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .subtitle
        label.adjustsFontSizeToFitWidth = true
        label.textColor = Colors.Text.secondary
        label.isHidden = true
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

    private lazy var callBarButtonItem = UIBarButtonItem(
        symbol: .phone,
        type: .normal,
        target: self,
        action: #selector(callAction)
    )

    private lazy var facetimeBarButtonItem = UIBarButtonItem(
        symbol: .video,
        type: .normal,
        target: self,
        action: #selector(facetimeAction)
    )

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
    
    private lazy var micLongPressGesture: UILongPressGestureRecognizer = {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio(gesture:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        return longPressGestureRecognizer
    }()

    private lazy var micUpSwipeGesure: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recordAudio(gesture:)))
        swipeGestureRecognizer.direction = .up
        return swipeGestureRecognizer
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
        configureNavBar()
        startSkeleton()
        getRecipientData()
        createTypingObserver()
        configureMessageInputBar()
        configureMessageCollectionView()
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
    }
    
    deinit {
        removeListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
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

    private func updateShowCallButtons(_ isNeedShow: Bool) {
        self.callBarButtonItem.tintColor = isNeedShow ? Colors.Elements.element : .clear
        self.facetimeBarButtonItem.tintColor = isNeedShow ? Colors.Elements.element : .clear
        self.callBarButtonItem.isEnabled = isNeedShow
        self.facetimeBarButtonItem.isEnabled = isNeedShow
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
                    guard recipientData.phone != nil else { return }
                    UIView.animate(withDuration: 0.3) {
                        self.updateShowCallButtons(true)
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
        messagesCollectionView.register(
            DAudioMessageCell.self,
            forCellWithReuseIdentifier: DAudioMessageCell.reuseIdentifier
        )
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
    
    func updateMicButtonStatus(show: Bool) {
        messageInputBar.setStackViewItems([show ? micButton : messageInputBar.sendButton], forStack: .right, animated: false)
    }
        
    private func configureNavBar() {
        updateShowCallButtons(false)
        setupBaseNavBar(rightBarButtonItems: [facetimeBarButtonItem, callBarButtonItem])
        configureCustomTitle()
    }
    
    private func configureCustomTitle() {
        guard !leftBarButtonView.contains(titleLabel) else { return }
        leftBarButtonView.addSubview(avatarImageView)
        leftBarButtonView.isUserInteractionEnabled = true
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(Constants.avatarSize)
            make.left.top.bottom.equalToSuperview()
        }

        let titleAndSubtitleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel], axis: .vertical, spacing: 5)
        leftBarButtonView.addSubview(titleAndSubtitleStackView)
        titleAndSubtitleStackView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top).offset(2)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(-3)
            make.width.equalTo(UIScreen.main.bounds.size.width - 48 - 176)
        }
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
    }
    
    @objc private func openRecipientAccountInfo() {
        print("aspdkasdoikasdioasd")
        guard let recipientData = recipientData else { return }
        let aboutUserVC = AboutUserVC(userData: recipientData, preloadedUserImage: avatarImageView.image)
        navigationController?.pushViewController(aboutUserVC, animated: true)
    }
    
    // MARK: - Load chats
    private func loadChats() {
        let predicate = NSPredicate(format: "\(GlobalConstants.kCHATROOMID) = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(
            byKeyPath: GlobalConstants.kDATE,
            ascending: true
        )

        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ [weak self] ( changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                self?.insertMessages()
                self?.messagesCollectionView.reloadData()
                print("asidojsadiojasdiojasdiojasdsa")
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
                    print("asdiojasoidjasd: ", Thread.isMainThread)
                    if isLastSectionVisible == true {
                        self?.messagesCollectionView.scrollToLastItem(animated: false)
                    }
//                        self?.messagesCollectionView.scrollToLastItem(animated: false)
//                    }
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
        print("asdoasjiodajiosdjoiasijod: ", Date().timeIntervalSinceNow)
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
        guard localMessage.senderId != AuthService.shared.currentUser!.id,
              localMessage.status != GlobalConstants.kREAD
        else { return }
        FirestoreService.shared.updateMessageInFirebase(
            localMessage,
            memberIds: [AuthService.shared.currentUser!.id, recipientId]
        )
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
        guard let phone = recipientData.phone else {
            print("ERROR_LOG Error get recipient phone")
            return
        }
        if let phoneUrl = URL(string: "tel://\(phone)") {
            let application = UIApplication.shared
            if (application.canOpenURL(phoneUrl)) {
                UIApplication.shared.open(phoneUrl)
            } else {
                showErrorCall()
                print("ERROR_LOG Error make phone call for phone number: ", phone)
            }
        } else {
            showErrorCall()
            print("ERROR_LOG Error get url from phone number: ", phone)
        }
    }
    
    @objc private func facetimeAction() {
        guard let recipientData = recipientData else {
            print("ERROR_LOG Error unwrap recipientData")
            return
        }
        guard let phone = recipientData.phone else {
            print("ERROR_LOG Error get recipient phone")
            return
        }
        if let facetimeUrl = URL(string: "facetime://\(phone)") {
            let application = UIApplication.shared
            if (application.canOpenURL(facetimeUrl)) {
                application.open(facetimeUrl)
            } else {
                showErrorCall()
                print("ERROR_LOG Error make facetime call for phone number: ", phone)
            }
        } else {
            showErrorCall()
            print("ERROR_LOG Error get url from phone number: ", phone)
        }
    }

    private func showErrorCall() {
        SPAlert.present(
            title: "Невозможно выполнить звонок",
            message: "Возможно номер пользователя недействителен",
            preset: .error
        )
    }
    
    @objc private func actionAttachMessage() {
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.view.tintColor = Colors.Elements.element
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
        print("aisdjaisodjaoisdjaoisdj: ", gesture)
        if gesture == micUpSwipeGesure {
            confgureAudioRecordForStart()
            let messageViewHeight = messageInputBar.calculateIntrinsicContentSize().height + view.safeAreaInsets.bottom
            let maxRightPosX = view.frame.size.width - Constants.rightRecordButtonPadding
            yPos = view.frame.size.height - (messageViewHeight / 2) - (audioRecordButton.frame.size.height / 4)
            gesture.state = .cancelled
            audioRecordView.setTapToCancel()
            audioRecordButton.update(center: CGPoint(x: maxRightPosX, y: yPos), state: .stayRecord, animated: false)
            view.addSubview(audioRecordButton)
        } else {
            let location = gesture.location(in: view)
            switch gesture.state {
            case .began:
                audioRecordView.setSwipeToCancel()
                audioRecordView.startInfoLabelAnimation()
                confgureAudioRecordForStart()
                let messageViewHeight = messageInputBar.calculateIntrinsicContentSize().height + view.safeAreaInsets.bottom
                yPos = view.frame.size.height - (messageViewHeight / 2) - (audioRecordButton.frame.size.height / 3)
                audioRecordButton.update(center: CGPoint(x: location.x, y: yPos), state: .record)
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
    }

    private func confgureAudioRecordForStart() {
        configureAudioRecordView()
        vibrate()
        audioDuration = Date()
        audioFileName = DateFormatter.ddMMyyyyHHmmss.string(from: Date())
        AudioRecorder.shared.startRecording(fileName: audioFileName)
        messageInputBar.isHidden = true
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
        subtitleLabel.isHidden = subtitleLabel.text?.isEmpty ?? true
    }
    
    func isLastSectionVisible() -> Bool {
        guard !mkMessages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: mkMessages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
        return !isPreviusMessageSameDay(at: indexPath)
    }

    func isPreviusMessageSameDay(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        let firstCalendarDate = Calendar.current.dateComponents([.day, .year, .month], from: mkMessages[indexPath.section].sentDate)
        let secondCalendarDate = Calendar.current.dateComponents([.day, .year, .month], from: mkMessages[indexPath.section - 1].sentDate)
        let sameDay = firstCalendarDate.day == secondCalendarDate.day
        let sameMonth = firstCalendarDate.month == secondCalendarDate.month
        let sameYear = firstCalendarDate.year == secondCalendarDate.year
        return sameDay && sameMonth && sameYear
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

// MARK: - Configure MessageInputBar
extension NewChatVC {
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        updateMicButtonStatus(show: true)
        messageInputBar.isTranslucent = true
        messageInputBar.inputTextView.delegate = self
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .clear
        messageInputBar.backgroundColor = .clear
        messageInputBar.layer.cornerRadius = 40
        messageInputBar.layer.cornerCurve = .continuous
        messageInputBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        messageInputBar.layer.masksToBounds = true
        messageInputBar.padding = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        messageInputBar.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
//        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        messageInputBar.layer.shadowRadius = 5
//        messageInputBar.layer.shadowOpacity = 0.3
//        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        configureInputTextView()
        configureSendButton()
        configureAttachButton()
    }

    private func configureInputTextView() {
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.placeholderTextColor = Colors.Text.placeholder
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 16, left: 44, bottom: 16, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 12)
        messageInputBar.inputTextView.layer.borderColor = Colors.Elements.line.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1
        messageInputBar.inputTextView.layer.cornerRadius = 24.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        messageInputBar.inputTextView.placeholder = Constants.messagePlaceholder
        messageInputBar.inputTextView.font = .placeholder
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
            view.addSubview(audioRecordButton)
            audioRecordView.layer.cornerCurve = .continuous
            audioRecordView.layer.cornerRadius = messageInputBar.layer.cornerRadius
            audioRecordView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            audioRecordView.layer.masksToBounds = true
        }
        audioRecordView.isHidden = false
    }

    func configureAttachButton() {
        let attachButton = InputBarButtonItem(type: .system)
        attachButton.tintColor = Colors.Elements.element
        let paperclipImage = UIImage(.paperclip).withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(
            ofSize: ButtonSymbolType.small.size,
            weight: ButtonSymbolType.small.weight
        )))
        attachButton.image = paperclipImage
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
}

extension NewChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.messageInputBar.inputTextView.layer.borderColor = Colors.Elements.element.cgColor
        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.messageInputBar.inputTextView.layer.borderColor = Colors.Elements.line.cgColor
        }
    }
}
