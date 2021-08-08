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
    
final class NewChatVC: MessagesViewController {
    
    private enum Constants {
        static let attachButtonSize: CGSize = CGSize(width: 44, height: 44)
        static let micButtonSize: CGSize = CGSize(width: 44, height: 44)
    }
    
    // MARK: - UI Elements
    private let refreshController: UIRefreshControl = {
        let refreshController = UIRefreshControl()
        return refreshController
    }()
    
    private let micButton: InputBarButtonItem = {
        let inputBarButtonItem = InputBarButtonItem(type: .system)
        inputBarButtonItem.image = UIImage(systemName: "mic")
        inputBarButtonItem.setSize(Constants.micButtonSize, animated: false)
  
        return inputBarButtonItem
    }()
    
    private let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: 140, height: 25))
        label.textAlignment = .left
        label.font = UIFont.sfProRounded(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 5, y: 22, width: 140, height: 20))
        label.textAlignment = .left
        label.font = UIFont.sfProRounded(ofSize: 12, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: - Listeners
    var notificationToken: NotificationToken?
    
    // MARK: - Properties
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    private let realm = try! Realm()
    
    private let chatId: String
    private let recipientId: String
    private let recipientName: String
    
    let currentUser = MKSender(senderId: AuthService.shared.currentUser!.id, displayName: AuthService.shared.currentUser!.username)
    
    // MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = recipientName
        configureMessageCollectionView()
        configureMessageInputBar()
        configureLeftBarButton()
        configureCustomTitle()
        loadChats()
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
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem(type: .system)
        attachButton.tintColor = .systemTeal
        let attachButtonImage = UIImage(systemName: "paperclip")!
        attachButton.image = attachButtonImage
        attachButton.setSize(Constants.attachButtonSize, animated: false)
        attachButton.addTarget(self, action: #selector(showPaperclipAlert),
                               for: .primaryActionTriggered)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recipientName
    }
    
    // MARK: - Load chats
    private func loadChats() {
        let predicate = NSPredicate(format: "\(GlobalConstants.kCHATROOMID) = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: GlobalConstants.kDATE, ascending: true)
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            switch changes {
            
            case .initial(_):
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            case .update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
            case .error(let error):
                print("ERROR_LOG Error on new insertion ", error.localizedDescription)
            }
        })
    }
    
    private func insertMessages() {
     
        for message in allLocalMessages {
            insertMessage(message)
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        if let mkMessage = incoming.createMessage(localMessage: localMessage) {
            self.mkMessages.append(mkMessage)
        } else {
            print("ERROR_LOG Cannot convert local message: \(localMessage) to MKMessage")
        }
    }
    
    // MARK: - Actions
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [AuthService.shared.currentUser!.id, recipientId])
    }
    
    @objc private func backButtonPressed() {
        // TODO: remove listeners
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func showPaperclipAlert() {
        
    }
    
    // MARK: - Update typing indicator
    func updateTypingIndicator(_ show: Bool) {
        subtitleLabel.text = show ? "Печатает..." : ""
    }
}
