//
//  WaitingGuestsVC.swift
//  Darty
//
//  Created by Руслан Садыков on 22.07.2021.
//

import UIKit
import SPAlert

class WaitingGuestsVC: UIViewController {
    
    // enum по умолчанию hashable
    enum Section: Int, CaseIterable {
        case users
        
        func description(usersCount: Int) -> String {
            switch self {
            
            case .users:
                if usersCount < 1 || usersCount > 5 {
                    return "\(usersCount) заявок"
                } else if usersCount == 1 {
                    return "\(usersCount) заявка"
                } else if usersCount > 1 && usersCount < 5 {
                    return "\(usersCount) заявки"
                } else {
                    return "\(usersCount) заявок"
                }
            }
        }
    }
    
    private var users = [UserModel]()
    private var party: PartyModel
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, UserModel>!
    
    init(users: [UserModel], party: PartyModel) {
        self.users = users
        self.party = party
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        setupCollectionView()
        createDataSource()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    }
    
    deinit {
        print("deinit", WaitingGuestsVC.self)
    }
    
    // MARK: - Handlers
    @objc private func changeToRejected(_ sender: UIButton) {
        let user = users[sender.tag]
        FirestoreService.shared.changeToRejected(user: user, party: party) { (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Заявка пользователя \(user.username) была отклонена", preset: .done)
                self.users.removeAll { $0.id == user.id }
                #warning("Тут краш")
                self.collectionView.deleteItems(at: [[0, sender.tag]])
                self.collectionView.reloadData()
            case .failure(let error):
                SPAlert.present(title: "Не удалось отправить заявку: \(error.localizedDescription)", preset: .error)
            }
        }
    }
    
    @objc private func changeToApproved(_ sender: UIButton) {
        let user = users[sender.tag]
        FirestoreService.shared.changeToApproved(user: user, party: party) { (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Приятно проведите время с \(user.username)", preset: .done)
                self.users.removeAll { $0.id == user.id }
                #warning("Тут краш")
                self.collectionView.deleteItems(at: [[0, sender.tag]])
                self.collectionView.reloadData()
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
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Cannot create new section header") }
            
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            
            // Достучались до всех объектов в секции parties
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            
            sectionHeader.configure(text: section.description(usersCount: items.count), font: .sfProRounded(ofSize: 26, weight: .medium), textColor: .label)
            
            return sectionHeader
        }
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
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        return sectionHeader
    }
}

// MARK: - UICollectionViewDelegate
extension WaitingGuestsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else {
            print("asdijasdiojasdioajsdiojs")
            return }
        print("asidojasoidjasoidjaoisdjasdias9da9sdj")
        let aboutUserVC = AboutUserVC(userData: user, type: .partyRequest)
        navigationController?.pushViewController(aboutUserVC, animated: true)
//        let partyRequestVC = PartyRequestViewController(user: user)
//        partyRequestVC.delegate = self
//        present(partyRequestVC, animated: true, completion: nil)
    }
}
