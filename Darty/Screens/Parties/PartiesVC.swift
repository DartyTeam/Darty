//
//  PartiesVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseFirestore
import FittedSheets

final class PartiesVC: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    
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
    
    private var rejectedPartiesListener: ListenerRegistration?
    private var rejectedParties = [PartyModel]()
    private var waitingPartiesListener: ListenerRegistration?
    private var waitingParties = [PartyModel]()
    private var approvedPartiesListener: ListenerRegistration?
    private var approvedParties = [PartyModel]()
    private var myPartiesListener: ListenerRegistration?
    private var myParties = [PartyModel]()
    
    private var myPartyRequestsListeners: [ListenerRegistration]?
    private var myPartyRequests = [String: [PartyRequestModel]]()
    private var partiesRequestsListenerDelegate: PartiesRequestsListenerProtocol?
    
    private let currentUser: UserModel
    private var type = AboutPartyVCType.search
    
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        createDataSource()
        reloadData(with: nil)
        setupListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StoreReviewHelper.checkAndAskForReview()
    }
    
    private func setupListeners() {
        rejectedPartiesListener = ListenerService.shared.rejectedPartiesObserve(parties: waitingParties, completion: { (result) in
            switch result {
        
            case .success(let parties):
                self.rejectedParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        })
        
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
                self.myPartyRequestsListeners?.forEach({ myPartyRequestListener in
                    myPartyRequestListener.remove()
                })
                self.myPartyRequestsListeners?.removeAll()
                
                parties.forEach { party in
                    var partyRequests = [PartyRequestModel]()
                    if let partyRequestsForParty = self.myPartyRequests[party.id] {
                        partyRequests = partyRequestsForParty
                    }
                    let myPartyRequestsListener = ListenerService.shared.waitingGuestsRequestsObserve(waitingGuestsRequests: partyRequests, partyId: party.id, completion: { (result) in
                        switch result {
                        case .success(let partyRequests):
                            self.myPartyRequests[party.id] = partyRequests
                            self.partiesRequestsListenerDelegate?.partyRequestsDidChange(self.myPartyRequests[party.id]!)
                            self.reloadPartiesType()
                        case .failure(let error):
                            self.showAlert(title: "Ошибка!", message: error.localizedDescription)
                        }
                    })
                    if let myPartyRequestsListener = myPartyRequestsListener {
                        self.myPartyRequestsListeners?.append(myPartyRequestsListener)
                    }
                }
            case .failure(let error):
                self.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        })
    }

    private func setupNavigationBar() {
        setNavigationBar(withColor: .systemPurple, title: "Поиск вечеринки", withClear: false)
        
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 18, weight: .semibold))
        let archiveBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "archivebox", withConfiguration: boldConfig)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(archiveAction))
        let filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet", withConfiguration: boldConfig)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(filterAction))
        let spaceItem = UIBarButtonItem()
        navigationItem.rightBarButtonItems = [archiveBarButtonItem, filterBarButtonItem, spaceItem, spaceItem, spaceItem]
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = collectionView
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
        dataSource?.apply(snapshot, animatingDifferences: true, completion: {
            if self.navigationItem.searchController == nil {
                self.setupSearchBar()
            }
        })
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
        #warning("Из-за этого не скрывается навигационный бар")
        searchController.searchBar.showsScopeBar = true // Из-за этого не скрывается навигационный бар
        searchController.searchBar.selectedScopeButtonIndex = 0
        
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = true
        
        // Make sure the search bar is showing, even when scrolling
//        navigationItem.hidesSearchBarWhenScrolling = true

        // Add the search controller to the nav item
        navigationItem.searchController = searchController
    }
    
    // MARK: - Handlers
    @objc private func reloadPartiesType() {
        let index = searchController.searchBar.selectedScopeButtonIndex
        switch searchController.searchBar.scopeButtonTitles![index] {
        case scopeTitles[0]:
            searchParties(filter: [String : String]())
            type = .search
        case scopeTitles[1]:
            parties = approvedParties
            type = .approved
        case scopeTitles[2]:
            parties = waitingParties + rejectedParties
            type = .waiting
        case scopeTitles[3]:
            parties = myParties
            type = .my
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
        let options = SheetOptions(
            // The full height of the pull bar. The presented view controller will treat this area as a safearea inset on the top
            pullBarHeight: 0,
            
            // The corner radius of the shrunken presenting view controller
            presentingViewCornerRadius: 30,
            
            // Extends the background behind the pull bar or not
            shouldExtendBackground: false,
            
            // Attempts to use intrinsic heights on navigation controllers. This does not work well in combination with keyboards without your code handling it.
            setIntrinsicHeightOnNavigationControllers: false,
            
            // Pulls the view controller behind the safe area top, especially useful when embedding navigation controllers
            useFullScreenMode: false,
            
            // Shrinks the presenting view controller, similar to the native modal
            shrinkPresentingViewController: false,
            
            // Determines if using inline mode or not
            useInlineMode: false,
            
            // Adds a padding on the left and right of the sheet with this amount. Defaults to zero (no padding)
            horizontalPadding: 0,
            
            // Sets the maximum width allowed for the sheet. This defaults to nil and doesn't limit the width.
            maxWidth: nil
        )
        
        print("asdkojasdiojasdoiajsda")
        let filterVC = FilterVC(delegate: self)
        let sheetController = SheetViewController(controller: filterVC, sizes: [], options: options)
        sheetController.contentBackgroundColor = .clear
        sheetController.cornerRadius = 30
        sheetController.shouldRecognizePanGestureWithUIControls = false
        present(sheetController, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit", PartiesVC.self)
        rejectedPartiesListener?.remove()
        waitingPartiesListener?.remove()
        approvedPartiesListener?.remove()
        myPartiesListener?.remove()
        myPartyRequestsListeners?.forEach({ listener in
            listener.remove()
        })
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
                let cell = self?.configure(collectionView: collectionView, cellType: PartyCell.self, with: party, for: indexPath)
                    
                if let party = self?.dataSource.itemIdentifier(for: indexPath) {
                    if self?.rejectedParties.contains(party) ?? false {
                        cell?.setRejected()
                    } else if self?.myParties.contains(party) ?? false {
                        if let countRequests = self?.myPartyRequests[party.id]?.count {
                            cell?.setRequests(count: countRequests)
                        }
                    }
                }
              
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Cannot create new section header") }
            
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            
            // Достучались до всех объектов в секции parties
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .parties)
            
            sectionHeader.configure(text: section.description(partiesCount: items.count), font: .sfProRounded(ofSize: 26, weight: .medium), textColor: .label, alignment: .natural)
            
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180))
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
        let aboutPartyVC = AboutPartyVC(party: party, type: type)
        if type == .my {
            if let partyRequests = myPartyRequests[party.id] {
                aboutPartyVC.partyRequestsDidChange(partyRequests)
            }
            partiesRequestsListenerDelegate = aboutPartyVC
        }
        navigationController?.pushViewController(aboutPartyVC, animated: true)
    }
}

// MARK: - Search parties
extension PartiesVC {
    @objc private func searchParties(filter: [String: Any]) {
        FirestoreService.shared.searchPartiesWith(city: filter["city"] as? String, type: filter["type"] as? PartyType, date: filter["date"] as? Date, dateSign: filter["dateSign"] as? QuerySign, maxGuestsLower: filter["maxGuestsLower"] as? Int, maxGuestsUpper: filter["maxGuestsUpper"] as? Int, priceLower: filter["priceLower"] as? Int, priceUpper: filter["priceUpper"] as? Int) { [weak self] (result) in
            
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
////
//                if filter["charPrice"] as? String == ">" {
//                    if let price = filter["price"] as? String, price != "" {  self?.searchedParties.removeAll(where: { $0.price < price }) }
//                } else if filter["charPrice"] as? String == "<" {
//                    if let price = filter["price"] as? String, price != "" { self?.searchedParties.removeAll(where: { $0.price > price }) }
//                } else if filter["charPrice"] as? String == "=" {
//                    if let price = filter["price"] as? String, price != "" { self?.searchedParties.removeAll(where: { $0.price != price }) }
//                }
                
                self?.parties = self?.searchedParties ?? [PartyModel]()
                
                print("asdmasoidjasdioajsdiosj: ", self?.parties, self?.parties.count)
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

extension PartiesVC: FilterVCDelegate {
    func didChangeFilter(_ filter: [String : Any]) {
        searchParties(filter: filter)
    }
}
