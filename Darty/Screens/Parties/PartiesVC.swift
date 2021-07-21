//
//  PartiesVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseFirestore

final class PartiesVC: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Collection view
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, PartyModel>!
    
    // enum по умолчанию hashable
    enum Section: Int, CaseIterable {
        case parties
        
        func description(partiesCount: Int) -> String {
            switch self {
            
            case .parties:
                return partiesCount.parties()
            }
        }
    }
    
    // MARK: - Properties
    private var scopeTitles = ["􀊫", "􀆅", "􀇲", "􀉩"]
    
    private var parties = [PartyModel]()
    private var searchedParties = [PartyModel]()
    
    private var waitingPartiesListener: ListenerRegistration?
    private var waitingParties = [PartyModel]()
    private var approvedPartiesListener: ListenerRegistration?
    private var approvedParties = [PartyModel]()
    private var myPartiesListener: ListenerRegistration?
    private var myParties = [PartyModel]()
    
    private let currentUser: UserModel
    private var target = ""
    
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupCollectionView()
        createDataSource()
        reloadData(with: nil)
        setupSearchBar()
        setupListeners()
    }
    
    private func setupListeners() {
        waitingPartiesListener = ListenerService.shared.waitingPartiesObserve(parties: waitingParties, completion: { (result) in
            switch result {
        
            case .success(let parties):
                self.waitingParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        })
        
        approvedPartiesListener = ListenerService.shared.approvedPartiesObserve(parties: approvedParties, completion: { (result) in
            switch result {
        
            case .success(let parties):
                self.approvedParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        })
        
        myPartiesListener = ListenerService.shared.myPartiesObserve(parties: myParties, completion: { (result) in
            switch result {
        
            case .success(let parties):
                self.myParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        })
    }

    private func setupNavigationBar() {
        setNavigationBar(withColor: .systemPurple, title: "Поиск вечеринки", withClear: false)
        
        let archiveBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "archivebox")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(archiveAction))
        let filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(filterAction))
        let spaceItem = UIBarButtonItem()
        navigationItem.rightBarButtonItems = [archiveBarButtonItem, filterBarButtonItem, spaceItem, spaceItem]
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(PartyCell.self, forCellWithReuseIdentifier: PartyCell.reuseId)
        
        collectionView.delegate = self
    }
    
    // Отвечает за заполнение реальными данными. Создает snapshot, добавляет нужные айтемы в нужные секции и регистрируется на dataSource
    private func reloadData(with searchText: String?) {
        let filteredParties = parties.filter { (party) -> Bool in
            party.contains(filter: searchText)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PartyModel>()
        snapshot.appendSections([.parties])
        snapshot.appendItems(filteredParties, toSection: .parties)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupSearchBar() {
        searchController.searchBar.placeholder = "Поиск"
        
        definesPresentationContext = true // Позволяет отпустить строку поиска, при переходе на другой экран
        searchController.searchBar.delegate = self

        searchController.searchBar.scopeButtonTitles = scopeTitles

        let attrs = [
            NSAttributedString.Key.font: UIFont.sfProDisplay(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.systemOrange
        ]
        searchController.searchBar.setScopeBarButtonTitleTextAttributes(attrs, for: .normal)
        // Make sure the scope bar is always showing, even when not actively searching
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.selectedScopeButtonIndex = 0

        // Make sure the search bar is showing, even when scrolling
        navigationItem.hidesSearchBarWhenScrolling = true

        // Add the search controller to the nav item
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = true
    }
    
    // MARK: - Handlers
    @objc private func reloadPartiesType() {
        let index = searchController.searchBar.selectedScopeButtonIndex
        switch searchController.searchBar.scopeButtonTitles![index] {
        case scopeTitles[0]:
            print("asdouasuhdihiuasduhiasuhiduahisd")
            searchParties(filter: [String : String]())
            target = "searched"
        case scopeTitles[1]:
            parties = approvedParties
            target = "approved"
        case scopeTitles[2]:
            parties = waitingParties
            target = "waiting"
        case scopeTitles[3]:
            print("asdioaksdioasdioajsd")
            parties = myParties
            target = "my"
        default:
            break
        }

        reloadData(with: nil)

        // Костыльно наверное. Нужно чтобы число вечеринок обновлялось
        collectionView.reloadData()
    }
    
    @objc private func archiveAction() {
        
    }
    
    @objc private func filterAction() {
        
    }
    
    deinit {
        print("deinit", PartiesVC.self)
        waitingPartiesListener?.remove()
        approvedPartiesListener?.remove()
        myPartiesListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UISearchBarDelegate
extension PartiesVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadData(with: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        reloadPartiesType()
        print("New scope index is now \(selectedScope)")
    }
}

// MARK: - Data Source
extension PartiesVC {
    
    // Отвечает за то, в каких секциях буду те или иные ячейки
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PartyModel>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, party) -> UICollectionViewCell? in
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Неизвестная секция для ячейки")
            }
            
            switch section {
            
            case .parties:
                return self?.configure(collectionView: collectionView, cellType: PartyCell.self, with: party, for: indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Cannot create new section header") }
            
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            
            // Достучались до всех объектов в секции parties
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .parties)
            
            sectionHeader.configure(text: section.description(partiesCount: items.count), font: .sfProRounded(ofSize: 26, weight: .medium), textColor: .label)
            
            return sectionHeader
        }
    }
}

// MARK: - Setup layout
extension PartiesVC {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Неизвестная секция для ячейки")
            }
            
            switch section {
            
            case .parties:
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(224))
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
extension PartiesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let party = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
//        let showPartyVC = ShowPartyViewController(party: party, target: target)
//        present(showPartyVC, animated: true, completion: nil)
    }
}

// MARK: - Search parties
extension PartiesVC {
    @objc private func searchParties(filter: [String: String]) {
        FirestoreService.shared.searchPartiesWith(city: filter["city"], type: filter["type"], date: filter["date"], countPeoples: filter["countPeoples"], price: filter["price"], charCountPeoples: filter["charCountPeoples"], charPrice: filter["charPrice"]) { [weak self] (result) in
            
            switch result {
            
            case .success(let parties):
           
                print("asdijasdiijaosdjoiasdiojajoisd")
                self?.searchedParties = parties
                
//                if filter["charCountPeoples"] == ">" {
//                    if let countPeoples = filter["countPeoples"], countPeoples != "" { self?.searchedParties.removeAll(where: { $0.maximumPeople < countPeoples }) }
//                } else if filter["charCountPeoples"] == "<" {
//                    if let countPeoples = filter["countPeoples"], countPeoples != "" { self?.searchedParties.removeAll(where: { $0.maximumPeople > countPeoples }) }
//                } else if filter["charCountPeoples"] == "=" {
//                    if let countPeoples = filter["countPeoples"], countPeoples != "" { self?.searchedParties.removeAll(where: { $0.maximumPeople != countPeoples }) }
//                }
//
                if filter["charPrice"] == ">" {
                    if let price = filter["price"], price != "" {  self?.searchedParties.removeAll(where: { $0.price < price }) }
                } else if filter["charPrice"] == "<" {
                    if let price = filter["price"], price != "" { self?.searchedParties.removeAll(where: { $0.price > price }) }
                } else if filter["charPrice"] == "=" {
                    if let price = filter["price"], price != "" { self?.searchedParties.removeAll(where: { $0.price != price }) }
                }
                
                self?.parties = self?.searchedParties ?? [PartyModel]()
                
                print("asdmasoidjasdioajsdiosj: ", self?.parties)
                self?.reloadData(with: nil)
                
                // Костыльно наверное. Нужно чтобы число вечеринок обновлялось
                self?.collectionView.reloadData()
                
            case .failure(let error):
                self?.parties = [PartyModel]()
                print(error.localizedDescription)
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}

//extension PartiesVC: SearchPartyFilterDelegate {
//    func didChangeFilter(filter: [String : String]) {
//        searchParties(filter: filter)
//    }
//}
