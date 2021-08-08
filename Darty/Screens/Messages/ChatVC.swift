//
//  ChatVC.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatVC: MessagesViewController {
    
    private var messages: [MessageModel] = []
    private var messageListener: ListenerRegistration?
    
    private let user: UserModel
    private let chat: RecentChatModel
    private let friendData: UserModel
    private let friendImageView = UIImageView()
    
    init(user: UserModel, friendData: UserModel, chat: RecentChatModel) {
        self.user = user
        self.chat = chat
        self.friendData = friendData
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("deinit", ChatVC.self)
        messageListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageUrl = URL(string: friendData.avatarStringURL) {
            friendImageView.sd_setImage(with: imageUrl) { image, error, cache, url in
                self.friendImageView.focusOnFaces = true
            }
        }
       
        setNavBar()
        messagesCollectionView.backgroundColor = .systemBackground
        
        configureMessageInputBar()
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
//            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
//            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        setupListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
    }
    
    private func setupListener() {
//        messageListener = ListenerService.shared.messagesObserve(chat: chat, completion: { (result) in
//            switch result {
//
//            case .success(var message):
//                if let url = message.downloadURL {
//                    StorageService.shared.downloadImage(url: url) { [weak self] (result) in
//                        guard let self = self else { return }
//                        switch result {
//
//                        case .success(let image):
//                            message.image = image
//                            self.insertNewMessage(message: message)
//                        case .failure(let error):
//                            self.showAlert(title: "Ошибка", message: error.localizedDescription)
//                        }
//                    }
//                } else {
//                    self.insertNewMessage(message: message)
//                }
//
//            case .failure(let error):
//                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
//            }
//        })
    }
    
    private func setNavBar() {
        setNavigationBar(withColor:.systemTeal, title: chat.receiverName)
        let attrs = [
            NSAttributedString.Key.font: UIFont.sfProRounded(ofSize: 16, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = attrs as [NSAttributedString.Key : Any]
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 16, weight: .medium))

        let callBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "phone", withConfiguration: boldConfig)?.withTintColor(.systemTeal, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(callAction))
        
        let facetimeBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "video", withConfiguration: boldConfig)?.withTintColor(.systemTeal, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(facetimeAction))
        
        navigationItem.rightBarButtonItems = [facetimeBarButtonItem, callBarButtonItem]
    }
    
    private func insertNewMessage(message: MessageModel) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    // MARK: - Handlers
    @objc private func callAction() {
        
    }
    
    @objc private func facetimeAction() {
        
    }
    
    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    private func sendImage(image: UIImage) {
//        StorageService.shared.uploadImageMessage(photo: image, to: chat) { (result) in
//            switch result {
//
//            case .success(let url):
//                var message = MessageModel(user: self.user, image: image)
//                message.downloadURL = url
//
//                FirestoreService.shared.sendMessage(chat: self.chat, message: message) { (result) in
//                    switch result {
//                    case .success():
//                        self.messagesCollectionView.scrollToBottom()
//                    case .failure(_):
//                        self.showAlert(title: "Ошибка!", message: "Сообщение не доставлено")
//                    }
//                }
//            case .failure(let error):
//                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
//            }
//        }
    }
}

// MARK: - ConfigureMessageInputBar
extension ChatVC {
    
    func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .systemGray
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 0.4033635232)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        configureCameraIcon()
    }
    
    func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "sendBlueIcon"), for: .normal)
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 30)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.middleContentViewPadding.right = -38
        messageInputBar.sendButton.title = nil
    }
    
    
    
    
    
    
    
    
    
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }

    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }

    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func configureCameraIcon() {
        let paperclipItem = InputBarButtonItem(type: .system)
        paperclipItem.tintColor = .systemTeal
        let paperclipItemImage = UIImage(systemName: "paperclip")!
        paperclipItem.image = paperclipItemImage
        
        paperclipItem.addTarget(self, action: #selector(showPaperclipAlert),
                             for: .primaryActionTriggered)
        
        paperclipItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        
        messageInputBar.setStackViewItems([paperclipItem], forStack: .left, animated: false)
    }
    
    @objc private func showPaperclipAlert() {
        let alert = UIAlertController(style: .actionSheet)
        alert.addAction(image: UIImage(systemName: "camera"), title: "Камера", color: .systemTeal, style: .default, isEnabled: true) { _ in
            self.cameraButtonPressed()
        }
        alert.show()
    }
}

// MARK: - MessagesDataSource
extension ChatVC: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return Sender(senderId: user.id, displayName: user.username) // id юзера, использующего приложение
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
  
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes:  [
                                        NSAttributedString.Key.font: UIFont.sfProDisplay(ofSize: 10, weight: .regular)!,
                                        NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
                #warning("Тут надо писать прочитано и проверять isRead в firestore")
                if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
                    return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
                }
                return nil
    }
    
    
    
}

// MARK: - MessagesLayoutDelegate
extension ChatVC: MessagesLayoutDelegate {
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 30
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        }
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatVC: MessagesDisplayDelegate {
  
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .white
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.systemTeal]
            }
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1).withAlphaComponent(0.25) : .systemTeal.withAlphaComponent(0.25)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(image: friendImageView.image, initials: "\(friendData.username.first)")
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 44, height: 44)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return isFromCurrentSender(message: message) ? .bubbleTail(.bottomRight, .pointedEdge) :  .bubbleTail(.bottomLeft, .pointedEdge)
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let message = MessageModel(user: user, content: text)
  
//        FirestoreService.shared.sendMessage(chat: chat, message: message) { (result) in
//            switch result {
//            
//            case .success():
//                self.messagesCollectionView.scrollToLastItem()
//            case .failure(let error):
//                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
//            }
//        }
        inputBar.inputTextView.text = ""
    }
}

extension ChatVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        sendImage(image: image)
    }
}

extension UIScrollView {
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForBottom: CGFloat {
      let scrollViewHeight = bounds.height
      let scrollContentSizeHeight = contentSize.height
      let bottomInset = contentInset.bottom
      let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
      return scrollViewBottomOffset
    }
}
