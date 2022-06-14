//
//  MessagesVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseFirestore
import SPAlert

class MessagesVC: BaseController {

    // MARK: - Constants
    private enum Constants {
        static let sectionsTextColor: UIColor = .label
        static let sectionsTextFont: UIFont? = .sfProRounded(ofSize: 16, weight: .bold)
        
        static let activeChatHeight: CGFloat = 64
        static let waitingChatHeight: CGFloat = 55
    }
    
    // MARK: - UI Elements
    private var collectionView: UICollectionView!
    private let noMessagesLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 24, weight: .medium)
        label.text = "Сообщений нет"
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Properties
    private var activeChats = [RecentChatModel]() {
        didSet {
            updateEmptyView()
        }
    }
    private var waitingChats = [RecentChatModel]() {
        didSet {
            updateEmptyView()
        }
    }
    
    // enum по умолчанию hashable
    enum Section: Int, CaseIterable {
        case waitingChats
        case activeChats
        
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Ожидающие чаты"
            case .activeChats:
                return "Активные чаты"
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, RecentChatModel>?
    
    private let currentUser: UserModel
    
    // MARK: - Init
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    deinit {
        print("deinit", MessagesVC.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Сообщения"
        setupCollectionView()
        setupViews()
        createDataSource()
        setupListeners()
        updateEmptyView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(false)
    }

    // MARK: - Setup
    private func setupListeners() {
        ListenerService.shared.recentWaitingChatsObserve(chats: waitingChats, completion: { [weak self] (result) in
            switch result {
            case .success(let chats):
                if let waitingChats = self?.waitingChats, waitingChats != [], waitingChats.count <= chats.count {
                    guard let chatData = chats.last else { return }
                    let userId = chatData.senderId
                    let aboutUserVC = AboutUserVC(userId: userId, chatData: chatData)
                    aboutUserVC.chatRequestDelegate = self
                    self?.navigationController?.pushViewController(aboutUserVC, animated: true)
                }
                self?.waitingChats = chats
                self?.reloadData(with: nil)
            case .failure(let error):
                self?.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        })
        
        ListenerService.shared.recentChatsObserve(recents: activeChats, completion: { [weak self] (result) in
            switch result {
            case .success(let chats):
                self?.activeChats = chats
                self?.reloadData(with: nil)
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
            }
        })
    }

    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.hidesNavigationBarDuringPresentation = true
        //        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
    }

    private func setupViews() {
        view.addSubview(noMessagesLabel)
        noMessagesLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
        }
    }
        
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseIdentifier)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseIdentifier)
        
        collectionView.delegate = self
    }

    // MARK: - Functions
    // Отвечает за заполнение реальными данными. Создает snapshot, добавляет нужные айтемы в нужные секции и регистрируется на dataSource
    private func reloadData(with searchText: String?) {
        let filteredActiveChats = activeChats.filter { (chat) -> Bool in
            chat.contains(filter: searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, RecentChatModel>()

        if !activeChats.isEmpty {
            snapshot.appendSections([.activeChats])
            snapshot.appendItems(activeChats, toSection: .activeChats)
        } else {
            snapshot.deleteSections([.activeChats])
            snapshot.deleteItems(activeChats)
        }

        if !waitingChats.isEmpty {
            snapshot.appendSections([.waitingChats])
            snapshot.appendItems(waitingChats, toSection: .waitingChats)
        } else {
            snapshot.deleteSections([.waitingChats])
            snapshot.deleteItems(waitingChats)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.collectionView.reloadData()
            if self?.navigationItem.searchController == nil {
                self?.setupSearchBar()
            }
        }
    }

    private func getSectionFor(index: Int) -> Section {
        guard var section = Section(rawValue: index) else { fatalError("Неизвестная секция для ячейки") }
        if self.waitingChats.isEmpty, let activeSection = Section(rawValue: 1) {
            section = activeSection
        }
        return section
    }
    
    // MARK: - Handlers
    private func removeWaitingChat(chat: RecentChatModel) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Чат с \(chat.receiverName) был удален", preset: .done)
            case .failure(let error):
                SPAlert.present(title: "Ошибка: \(error.localizedDescription)", preset: .error)
            }
        }
    }
    
    private func changeToActive(chat: RecentChatModel, user: UserModel) {
        FirestoreService.shared.changeToActive(chat: chat, user1: user, user2: currentUser) { (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Приятного общения с \(chat.receiverName)", preset: .done)
            case .failure(let error):
                SPAlert.present(title: "Ошибка: \(error.localizedDescription)", preset: .error)
            }
        }
    }
    
    func open(chat: RecentChatModel) {
        FirestoreService.shared.recreateChat(chatRoomId: chat.chatRoomId, memberIds: chat.memberIds) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
                print("ERROR_LOG Error recreate chat \(chat.chatRoomId): ", error.localizedDescription)
            }
        }
        let privateChatVC = NewChatVC(
            chatId: chat.chatRoomId,
            recipientId: chat.receiverId
        )
        privateChatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatVC, animated: true)
    }

    func updateEmptyView() {
        let isNoChats = waitingChats.isEmpty && activeChats.isEmpty
        noMessagesLabel.isHidden = !isNoChats
        searchController.searchBar.isHidden = isNoChats
    }
}

// MARK: - Data Source
extension MessagesVC {
    // Отвечает за то, в каких секциях буду те или иные ячейки
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, RecentChatModel>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let self = self else { fatalError("Error self safe unwrapping") }
            let section = self.getSectionFor(index: indexPath.section)
            switch section {
            case .activeChats:
                return self.configure(
                    collectionView: collectionView,
                    cellType: ActiveChatCell.self,
                    with: chat,
                    for: indexPath
                )
            case .waitingChats:
                return self.configure(
                    collectionView: collectionView,
                    cellType: WaitingChatCell.self,
                    with: chat,
                    for: indexPath
                )
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseId,
                for: indexPath
            ) as? SectionHeader
            else { fatalError("Cannot create new section header") }
            let section = self.getSectionFor(index: indexPath.section)
            sectionHeader.configure(
                text: section.description(),
                font: Constants.sectionsTextFont,
                textColor: Constants.sectionsTextColor,
                alignment: .center)
            return sectionHeader
        }
    }
}

// MARK: - Setup layout
extension MessagesVC {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { fatalError("Error self safe unwrapping") }
            let section = self.getSectionFor(index: sectionIndex)
            switch section {
            case .activeChats:
                return self.createActiveChats(layoutEnvironment: layoutEnvironment)
            case .waitingChats:
                return self.createWaitingChats()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        
        return layout
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.waitingChatHeight),
            heightDimension: .absolute(Constants.waitingChatHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 32, leading: 16, bottom: 0, trailing: 16)
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader()
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createActiveChats(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // section -> group -> item -> size
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(Constants.activeChatHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 32, leading: 16, bottom: 0, trailing: 16)
        
        let sectionHeader = createSectionHeader()
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return sectionHeader
    }
}

extension MessagesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadData(with: searchController.searchBar.text)
    }
}

// MARK: - UICollectionViewDelegate
extension MessagesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        let section = getSectionFor(index: indexPath.section)
        switch section {
        case .waitingChats:
            let aboutUserVC = AboutUserVC(userId: chat.senderId, chatData: chat)
            aboutUserVC.chatRequestDelegate = self
            navigationController?.pushViewController(aboutUserVC, animated: true)
        case .activeChats:
            open(chat: chat)
        }
    }
}

extension MessagesVC: AboutUserChatRequestDelegate {
    func userDidDecline(_ chat: RecentChatModel) {
        removeWaitingChat(chat: chat)
    }
    
    func userDidAccept(_ chat: RecentChatModel, user: UserModel) {
        changeToActive(chat: chat, user: user)
    }
}
