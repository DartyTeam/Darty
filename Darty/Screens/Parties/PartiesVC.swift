//
//  PartiesVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseFirestore
import FittedSheets

enum PartyListType: String, CaseIterable {
    case search = "􀊫"
    case approved = "􀆅"
    case waiting = "􀇲"
    case my = "􀉩"

    var title: String {
        switch self {
        case .search:
            return "Поиск вечеринок"
        case .approved:
            return "Подтвержденные вечеринки"
        case .waiting:
            return "Ожидающие вечеринки"
        case .my:
            return "Мои вечеринки"
        }
    }

    static var allCasesForSegmentedControl: [String] {
        var array = [String]()
        for item in self.allCases {
            array.append(item.rawValue)
        }
        return array
    }

    var index: Int {
        switch self {
        case .search:
            return 0
        case .approved:
            return 1
        case .waiting:
            return 2
        case .my:
            return 3
        }
    }

    static subscript(_ index: Int) -> PartyListType? {
        return PartyListType.allCases.first(where: { $0.index == index })
    }
}

final class PartiesVC: UIViewController {

    private struct Constants {
        static let segmentPartiesHorizontalInset: CGFloat = 32
        static let segmentPartiesTopOffset: CGFloat = 16
        static let errorListenerParty = "Ошибка"
    }
    // MARK: - UI Elements
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Нет вечеринок"
        label.font = .sfProDisplay(ofSize: 20, weight: .medium)
        return label
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    private let segmentedPartiesPages: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: PartyListType.allCasesForSegmentedControl)
        segmentedControl.addTarget(self, action: #selector(reloadPartiesType), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        let attrs: [NSAttributedString.Key : Any] = [
            .font: UIFont.sfProDisplay(ofSize: 16, weight: .semibold) ?? .systemFont(ofSize: 16),
            .foregroundColor: UIColor.systemOrange
        ]
        segmentedControl.setTitleTextAttributes(attrs, for: UIControl.State())
        return segmentedControl
    }()

    private let filterBarButtonItem = UIBarButtonItem(
        image: UIImage(.slider.horizontal_3)
            .withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(
                ofSize: 18,
                weight: .semibold
            )))
            .withTintColor(.systemOrange, renderingMode: .alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(filterAction)
    )
    
    // MARK: - Collection view
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, PartyModel>!
    
    // enum по умолчанию hashable
    enum Section: Int, CaseIterable {
        case parties
        case archived
        func description(partiesCount: Int) -> String {
            switch self {
            case .parties:
                return partiesCount.parties()
            case .archived:
                return "Прошедшие:"
            }
        }
    }
    
    // MARK: - Properties
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
    private var partyType = AboutPartyVCType.search

    private var isEmptyActualPaties = true

    // MARK: - Init
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupViews()
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

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(
                (view.bounds.size.height -
                 segmentedPartiesPages.frame.maxY + Constants.segmentPartiesTopOffset -
                 GlobalConstants.tabBarHeight) / 2.5 // Типо по центру, но на угад)
            )
        }
    }

    private func setupListeners() {
        rejectedPartiesListener = ListenerService.shared.rejectedPartiesObserve(parties: waitingParties, completion: { (result) in
            switch result {
            case .success(let parties):
                self.rejectedParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(
                    title: Constants.errorListenerParty,
                    message: error.localizedDescription
                )
            }
        })
        
        waitingPartiesListener = ListenerService.shared.waitingPartiesObserve(parties: waitingParties, completion: { (result) in
            switch result {
            case .success(let parties):
                self.waitingParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(
                    title: Constants.errorListenerParty,
                    message: error.localizedDescription
                )
            }
        })
        
        approvedPartiesListener = ListenerService.shared.approvedPartiesObserve(parties: approvedParties, completion: { (result) in
            switch result {
            case .success(let parties):
                self.approvedParties = parties
                self.reloadPartiesType()
            case .failure(let error):
                self.showAlert(
                    title: Constants.errorListenerParty,
                    message: error.localizedDescription
                )
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
                            self.showAlert(
                                title: Constants.errorListenerParty,
                                message: error.localizedDescription
                            )
                        }
                    })
                    if let myPartyRequestsListener = myPartyRequestsListener {
                        self.myPartyRequestsListeners?.append(myPartyRequestsListener)
                    }
                }
            case .failure(let error):
                self.showAlert(
                    title: Constants.errorListenerParty,
                    message: error.localizedDescription
                )
            }
        })
    }

    private func setupNavigationBar() {
        setNavigationBar(withColor: .systemPurple, title: "Поиск вечеринки", withClear: false)
        navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedPartiesPages)
        segmentedPartiesPages.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(
                view.bounds.size.width - Constants.segmentPartiesHorizontalInset
            )
            make.top.equalToSuperview().offset(
                -segmentedPartiesPages.bounds.size.height - Constants.segmentPartiesTopOffset
            )
        }
        additionalSafeAreaInsets.top = segmentedPartiesPages.bounds.size.height + Constants.segmentPartiesTopOffset
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = collectionView
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseId
        )
        collectionView.register(
            PartyCell.self,
            forCellWithReuseIdentifier: PartyCell.reuseId
        )
        collectionView.delegate = self
    }

    private func setupSearchBar() {
        searchController.searchBar.placeholder = "Поиск"

        definesPresentationContext = true // Позволяет отпустить строку поиска, при переходе на другой экран
        searchController.searchBar.delegate = self

        searchController.obscuresBackgroundDuringPresentation = false
        //        searchController.hidesNavigationBarDuringPresentation = true

        // Make sure the search bar is showing, even when scrolling
        navigationItem.hidesSearchBarWhenScrolling = true

        // Add the search controller to the nav item
        navigationItem.searchController = searchController
    }

    // MARK: - Functions
    // Отвечает за заполнение реальными данными. Создает snapshot, добавляет нужные айтемы в нужные секции и регистрируется на dataSource
    private func reloadData(with searchText: String?) {
        let filteredParties = parties.filter { (party) -> Bool in
            party.contains(filter: searchText)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PartyModel>()
        let isSearchListParties = segmentedPartiesPages.selectedSegmentIndex == PartyListType.search.index
        isEmptyActualPaties = filteredParties.isEmpty
        snapshot.appendSections([.parties, .archived])
        if !isSearchListParties  {
            print("asdijiasodjasdjasidjas")
            let archivedParties = filteredParties.filter( { $0.date < Date() } )
            let actualParties = filteredParties.filter( { $0.date >= Date() } )
            if actualParties.isEmpty {
                isEmptyActualPaties = true
                snapshot.deleteSections([.parties])
            } else {
                isEmptyActualPaties = false
                snapshot.appendItems(actualParties, toSection: .parties)
            }
            if archivedParties.isEmpty {
                snapshot.deleteSections([.archived])
            } else {
                snapshot.appendItems(archivedParties, toSection: .archived)
            }
            let isEmpty = actualParties.isEmpty && archivedParties.isEmpty
            update(isEmpty: isEmpty)
        } else {
            if filteredParties.isEmpty {
                snapshot.deleteSections([.parties])
                update(isEmpty: true)
            } else {
                snapshot.appendItems(filteredParties, toSection: .parties)
            }
            snapshot.deleteSections([.archived])
        }
        print("asdijaisodaiojsdoijasd: ", snapshot.numberOfSections)

        if dataSource.numberOfSections(in: collectionView) == 0,
           snapshot.numberOfSections == 0 {
            return
        }

        dataSource?.apply(snapshot, animatingDifferences: true, completion: { [weak self] in
            if self?.navigationItem.searchController == nil {
                self?.setupSearchBar()
            }
        })

        print("asdiojasiodasd: ", isEmptyActualPaties)
        guard !isEmptyActualPaties,
              let sectionHeader = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionHeader,
                at: [0,0]
              ) as? SectionHeader
        else {
            return
        }
        updateCountFor(sectionHeader: sectionHeader, section: .parties)
    }

    private func update(isEmpty: Bool) {
        emptyLabel.isHidden = !isEmpty
        searchController.searchBar.isUserInteractionEnabled = !isEmpty
        let isNeedShowFilterButton = !isEmpty && partyType == .search
        navigationItem.setRightBarButton(
            isNeedShowFilterButton ? filterBarButtonItem : nil,
            animated: true
        )
    }
    
    // MARK: - Handlers
    @objc private func reloadPartiesType() {
        let partyListType = PartyListType[segmentedPartiesPages.selectedSegmentIndex]
        title = partyListType?.title
        switch partyListType {
        case .search:
            searchParties(filterParams: FilterManager.shared.filterParams)
            partyType = .search
        case .approved:
            parties = approvedParties
            partyType = .approved
        case .waiting:
            parties = waitingParties + rejectedParties
            partyType = .waiting
        case .my:
            parties = myParties
            partyType = .my
        case .none:
            break
        }
        reloadData(with: nil)
    }

    func changeSelectedPartyList(type: PartyListType) {
        segmentedPartiesPages.selectedSegmentIndex = type.index
        segmentedPartiesPages.sendActions(for: .valueChanged)
    }
    
    @objc private func filterAction() {
        let options = GlobalConstants.sheetOptions
        let filterVC = FilterVC(delegate: self)
        let sheetController = SheetViewController(controller: filterVC, sizes: [.intrinsic], options: options)
        sheetController.contentBackgroundColor = .clear
        sheetController.cornerRadius = 30
        sheetController.shouldRecognizePanGestureWithUIControls = false
        sheetController.allowPullingPastMaxHeight = false
        present(sheetController, animated: true, completion: nil)
    }

    func openAbout(party: PartyModel) {
        let aboutPartyVC = AboutPartyVC(party: party, type: partyType)
        if partyType == .my {
            if let partyRequests = myPartyRequests[party.id] {
                aboutPartyVC.partyRequestsDidChange(partyRequests)
            }
            partiesRequestsListenerDelegate = aboutPartyVC
        }
        navigationController?.pushViewController(aboutPartyVC, animated: true)
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

    private func updateCountFor(sectionHeader: SectionHeader, section: Section) {
        // Достучались до всех объектов в секции parties
        let items = self.dataSource.snapshot().itemIdentifiers(inSection: section)
        sectionHeader.configure(
            text: section.description(partiesCount: items.count),
            font: .sfProRounded(ofSize: 26, weight: .medium),
            textColor: .label,
            alignment: .natural
        )
    }
}

// MARK: - Data Source
extension PartiesVC {
    // Отвечает за то, в каких секциях буду те или иные ячейки
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PartyModel>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, party) -> UICollectionViewCell? in

            let cell = self?.configure(collectionView: collectionView, cellType: PartyCell.self, with: party, for: indexPath)
            DispatchQueue.global(qos: .default).async {
                cell?.snapShotter.start { snapshot, error in
                    DispatchQueue.main.async {
                        let cell = collectionView.cellForItem(at: indexPath) as? PartyCell
                        cell?.setMap(image: snapshot?.image)
                    }
                }
            }

            FirestoreService.shared.getUser(by: party.userId) { (result) in
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        let cell = collectionView.cellForItem(at: indexPath) as? PartyCell
                        cell?.setUser(
                            rating: "000000",
                            username: user.username,
                            avatarStringUrl: user.avatarStringURL
                        )
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

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
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard
                let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseId,
                for: indexPath
            ) as? SectionHeader
            else {
                fatalError("Cannot create new section header")
            }
            let section = self.getSectionFor(index: indexPath.section)
            self.updateCountFor(sectionHeader: sectionHeader, section: section)
            return sectionHeader
        }
    }

    private func getSectionFor(index: Int) -> Section {
        guard var section = Section(rawValue: index)
        else {
            fatalError("Неизвестная секция для ячейки")
        }
        if isEmptyActualPaties, let archivedSection = Section(rawValue: 1) {
            section = archivedSection
        }
        return section
    }
}

// MARK: - Setup layout
extension PartiesVC {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            let section = self.getSectionFor(index: sectionIndex)
            switch section {
            case .parties:
                return self.createPartiesSection()
            case .archived:
                return self.createPartiesSection()
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
        openAbout(party: party)
    }
}

// MARK: - Search parties
extension PartiesVC {
    private func searchParties(filterParams: FilterManager.FilterParams) {
        let filterParams = FilterManager.shared.filterParams
        var isDateInSearch = false
        var isPriceInSearch = false
        var isGuestsInSearch = false

        if filterParams.dateSign != .isEqual {
            isDateInSearch = true
        } else if filterParams.priceLower != nil, filterParams.priceUpper != nil, filterParams.priceType == .money {
            isPriceInSearch = true
        } else if filterParams.maxGuestsLower != nil, filterParams.maxGuestsUpper != nil {
            isGuestsInSearch = true
        }

        FirestoreService.shared.searchPartiesWith(
            city: filterParams.city,
            type: filterParams.type,
            date: filterParams.date,
            dateSign: filterParams.dateSign,
            maxGuestsLower: filterParams.maxGuestsLower,
            maxGuestsUpper: filterParams.maxGuestsUpper,
            priceType: filterParams.priceType,
            priceLower: filterParams.priceLower,
            priceUpper: filterParams.priceUpper,
            isDateInSearch: isDateInSearch,
            isPriceInSearch: isPriceInSearch,
            isGuestsInSearch: isGuestsInSearch,
            ascType: filterParams.ascendingType,
            sortingType: filterParams.sortingType
        ) { [weak self] (result) in
            switch result {
            case .success(let parties):
                var parties = parties
                if !isGuestsInSearch, let maxGuestsLower = filterParams.maxGuestsLower, let maxGuestsUpper = filterParams.maxGuestsUpper {
                    parties = parties.filter { party in
                        party.maxGuests >= maxGuestsLower && party.maxGuests <= maxGuestsUpper
                    }
                }

                if !isDateInSearch, filterParams.dateSign != .isEqual {
                    parties = parties.filter { party in
                        if filterParams.dateSign == .isGreaterThanOrEqualTo {
                            return party.date >= filterParams.date
                        } else {
                            return party.date <= filterParams.date
                        }
                    }
                }

                if !isPriceInSearch,
                   let priceLower = filterParams.priceLower,
                   let priceUpper = filterParams.priceUpper,
                   filterParams.priceType == .money {
                    parties = parties.filter { party in
                        if let partyMoneyPrice = party.moneyPrice {
                            return partyMoneyPrice >= priceLower && partyMoneyPrice <= priceUpper
                        } else {
                            return false
                        }
                    }
                }

                parties = parties.filter { party in
                    party.userId != AuthService.shared.currentUser.id
                }

                switch filterParams.sortingType {
                case .date:
                    if !isDateInSearch {
                        parties.sort { firstParty, secondParty in
                            if filterParams.ascendingType == .desc {
                                return firstParty.date < secondParty.date
                            } else {
                                return firstParty.date > secondParty.date
                            }
                        }
                    }
                case .guests:
                    if !isGuestsInSearch {
                        parties.sort { firstParty, secondParty in
                            if filterParams.ascendingType == .desc {
                                return firstParty.maxGuests < secondParty.maxGuests
                            } else {
                                return firstParty.maxGuests > secondParty.maxGuests
                            }
                        }
                    }
                case .price:
                    if !isPriceInSearch {
                        parties.sort { firstParty, secondParty in
                            if filterParams.ascendingType == .desc {
                                return (firstParty.moneyPrice ?? 0) < (secondParty.moneyPrice ?? 0)
                            } else {
                                return (firstParty.moneyPrice ?? 0) > (secondParty.moneyPrice ?? 0)
                            }
                        }
                    }
                }

                self?.searchedParties = parties

                self?.parties = self?.searchedParties ?? [PartyModel]()
                
                print("asdmasoidjasdioajsdiosj: ", self?.parties, self?.parties.count)
                self?.reloadData(with: nil)
            case .failure(let error):
                self?.parties = [PartyModel]()
                print(error.localizedDescription)
                self?.showAlert(
                    title: Constants.errorListenerParty,
                    message: error.localizedDescription
                )
            }
        }
    }
}

// MARK: - FilterVCDelegate
extension PartiesVC: FilterVCDelegate {
    func didChangeFilter(_ filter: FilterManager.FilterParams) {
        searchParties(filterParams: filter)
    }
}
