//
//  WaitingGuestsVC.swift
//  Darty
//
//  Created by Руслан Садыков on 22.07.2021.
//

import UIKit
import SPAlert

class WaitingGuestsVC: BaseController, PartiesRequestsListenerProtocol {

    // enum по умолчанию hashable
    enum Section: Int, CaseIterable {
        case users
    }
    
    private var waitingGuestsRequests = [PartyRequestModel]()
    private var users: [UserModel] = []
    private var party: PartyModel
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, UserModel>!
    
    init(waitingGuestsRequests: [PartyRequestModel], party: PartyModel) {
        self.waitingGuestsRequests = waitingGuestsRequests
        self.party = party
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = waitingGuestsRequests.count.parties()
        clearNavBar = false
        getFirstUser()
        setupCollectionView()
        createDataSource()
        reloadData()
    }

    private func getFirstUser() {
        if let firstUserId = waitingGuestsRequests.first?.userId {
            getUser(by: firstUserId)
        }
    }
    
    func partyRequestsDidChange(_ partyRequests: [PartyRequestModel]) {
        waitingGuestsRequests = partyRequests
        users.removeAll()
        getFirstUser()
        reloadData()
    }
    
    private func getUser(by id: String) {
        FirestoreService.shared.getUser(by: id) { [weak self] result in
            
            switch result {
            
            case .success(let user):
                self?.users.append(user)
                self?.reloadData()
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(WaitingGuestCell.self, forCellWithReuseIdentifier: WaitingGuestCell.reuseId)
        
        collectionView.delegate = self
    }
    
    // Отвечает за заполнение реальными данными. Создает snapshot, добавляет нужные айтемы в нужные секции и регистрируется на dataSource
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserModel>()
        snapshot.appendSections([.users])
        snapshot.appendItems(users, toSection: .users)
        dataSource?.apply(snapshot, animatingDifferences: true)
        title = waitingGuestsRequests.count.parties()
    }
    
    deinit {
        print("deinit", WaitingGuestsVC.self)
    }
    
    // MARK: - Handlers
    @objc private func changeToRejected(_ sender: UIButton) {
        let user = users[sender.tag]
        changeToRejected(user: user)
    }
    
    private func changeToRejected(user: UserModel) {
        FirestoreService.shared.changeToRejected(user: user, party: party) { [weak self] (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Заявка пользователя \(user.username) была отклонена", preset: .done)
                self?.users.removeAll { $0.id == user.id }
                self?.waitingGuestsRequests.removeAll() { $0.userId == user.id }
                self?.reloadData()
             
            case .failure(let error):
                SPAlert.present(title: "Не удалось отправить заявку: \(error.localizedDescription)", preset: .error)
            }
        }
    }
    
    @objc private func changeToApproved(_ sender: UIButton) {
        let user = users[sender.tag]
        changeToApproved(user: user)
    }
    
    private func changeToApproved(user: UserModel) {
        FirestoreService.shared.changeToApproved(user: user, party: party) { [weak self] (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Приятно проведите время с \(user.username)", preset: .done)
                self?.users.removeAll { $0.id == user.id }
                self?.waitingGuestsRequests.removeAll() { $0.userId == user.id }
                self?.reloadData()
            case .failure(let error):
                SPAlert.present(title: "Не удалось отправить заявку: \(error.localizedDescription)", preset: .error)
            }
        }
    }
}

// MARK: - Data Source
extension WaitingGuestsVC {
    // Отвечает за то, в каких секциях буду те или иные ячейки
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, UserModel>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, user) -> UICollectionViewCell? in
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Неизвестная секция для ячейки")
            }
            
            switch section {
            
            case .users:
                let cell = self?.configure(collectionView: collectionView, cellType: WaitingGuestCell.self, with: user, for: indexPath)
                cell?.acceptButton.tag = indexPath.row
                cell?.acceptButton.addTarget(self, action: #selector(self?.changeToApproved(_:)), for: .touchDown)
                cell?.denyButton.tag = indexPath.row
                cell?.denyButton.addTarget(self, action: #selector(self?.changeToRejected(_:)), for: .touchDown)
                if let message = self?.waitingGuestsRequests[indexPath.row].message {
                    cell?.addMessageFromUser(message)
                }
                return cell
            }
        })
    }
}

// MARK: - Setup layout
extension WaitingGuestsVC {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Неизвестная секция для ячейки")
            }
            
            switch section {
            
            case .users:
                return self?.createPartiesSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        
        return layout
    }
    
    private func createPartiesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(128))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 16, bottom: 0, trailing: 16)
        
        return section
    }
}

// MARK: - UICollectionViewDelegate
extension WaitingGuestsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let message = waitingGuestsRequests[indexPath.row].message
        let aboutUserVC = AboutUserVC(userData: user, message: message)
        aboutUserVC.partyRequestDelegate = self
        navigationController?.pushViewController(aboutUserVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == users.count - 1 && waitingGuestsRequests.count > users.count {
            let userId = waitingGuestsRequests[indexPath.row + 1].userId
            getUser(by: userId)
        }
    }
}

extension WaitingGuestsVC: AboutUserPartyRequestDelegate {
    func userDidDecline(_ user: UserModel) {
        changeToRejected(user: user)
    }
    
    func userDidAccept(_ user: UserModel) {
        changeToApproved(user: user)
    }
}
