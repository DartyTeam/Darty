//
//  SearchInterestsSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 05.07.2021.
//

protocol SearchInterestsSetupProfileSelectionDelegate: AnyObject {
    func selected(interests: [Int])
}

enum MainButtonType {
    case done
    case save
}

import UIKit
import FirebaseAuth

final class SearchInterestsSetupProfileVC: BaseController {
        
    // MARK: - Constants
    private enum Constants {
        static let interestsCollectionViewInsets = UIEdgeInsets(top: 32, left: 20, bottom: 128, right: 20)
        static let mainButtonDoneTitle = "Готово 􀆅"
        static let mainButtonSaveTitle = "Сохранить 􀆅"
    }
    
    // MARK: - UI Elements
    private lazy var nextButton: DButton = {
        let button = DButton()
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var interestsCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        collectionView.register(InterestCell.self, forCellWithReuseIdentifier: InterestCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = Constants.interestsCollectionViewInsets
        return collectionView
    }()

    private let bottomView: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.layer.cornerCurve = .continuous
        blurEffectView.layer.masksToBounds = true
        return blurEffectView
    }()
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Properties
    private var isFiltering: Bool {
        return !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var filteredInterests: [InterestModel] = []
    
    private var selectedInterests = [Int]()

    // MARK: - Delegate
    weak var delegate: SearchInterestsSetupProfileDelegate?
    weak var selectionDelegate: SearchInterestsSetupProfileSelectionDelegate?

    // MARK: - Init
    init(selectedIntersests: [Int], mainButtonTitleType: MainButtonType) {
        super.init(nibName: nil, bundle: nil)
        switch mainButtonTitleType {
        case .done:
            nextButton.setTitle(Constants.mainButtonDoneTitle, for: UIControl.State())
        case .save:
            nextButton.setTitle(Constants.mainButtonSaveTitle, for: UIControl.State())
        }
        self.selectedInterests = selectedIntersests
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Интересы"
        clearNavBar = false
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        setupSearchBar()
        setupViews()
        setupConstraints()
        for interest in selectedInterests {
            interestsCollectionView.selectItem(
                at: IndexPath(item: interest, section: 0),
                animated: false,
                scrollPosition: .centeredVertically
            )
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard self.isMovingFromParent else { return }
        selectionDelegate?.selected(interests: selectedInterests)
    }

    // MARK: - Setup
    private func setupViews() {
        interestsCollectionView.contentInset = Constants.interestsCollectionViewInsets
        interestsCollectionView.verticalScrollIndicatorInsets.bottom = interestsCollectionView.contentInset.bottom
        view.backgroundColor = .systemBackground
        view.addSubview(interestsCollectionView)
        view.addSubview(bottomView)
        bottomView.contentView.addSubview(nextButton)
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
//        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск по интересам"
        definesPresentationContext = true
    }
    
    // MARK: - Handlers
    @objc private func keyboardWillHide(notification: NSNotification) {
        nextButton.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        interestsCollectionView.contentInset = Constants.interestsCollectionViewInsets
        interestsCollectionView.verticalScrollIndicatorInsets.bottom = interestsCollectionView.contentInset.bottom
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        interestsCollectionView.contentInset = UIEdgeInsets(
            top:  Constants.interestsCollectionViewInsets.top,
            left: Constants.interestsCollectionViewInsets.left,
            bottom: keyboardFrame.size.height,
            right:  Constants.interestsCollectionViewInsets.right
        )
        interestsCollectionView.verticalScrollIndicatorInsets.bottom = interestsCollectionView.contentInset.bottom
        
        nextButton.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalToSuperview().offset(-keyboardFrame.height - 24)
        }

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.mainButtonTapepd(with: selectedInterests)
    }
}

// MARK: - Setup constraints
extension SearchInterestsSetupProfileVC {
    private func setupConstraints() {
        bottomView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }

        interestsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SearchInterestsSetupProfileVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    private func filterContentForSearchText(_ searchText: String) {
        filteredInterests = ConfigService.shared.interestsArray.filter({ interest in
            interest.title.lowercased().contains(searchText.lowercased()) || interest.emoji.contains(searchText)
        })
        interestsCollectionView.reloadSections([0])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension SearchInterestsSetupProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? filteredInterests.count : ConfigService.shared.interestsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: InterestCell.reuseIdentifier,
            for: indexPath
        ) as! InterestCell
        let interest = isFiltering ? filteredInterests[indexPath.row] : ConfigService.shared.interestsArray[indexPath.row]
        cell.setupCell(title: interest.title, emoji: interest.emoji)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFiltering {
            selectedInterests.append(filteredInterests[indexPath.row].id)
        } else {
            selectedInterests.append(ConfigService.shared.interestsArray[indexPath.row].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isFiltering {
            selectedInterests.removeAll { $0 == filteredInterests[indexPath.row].id }
        } else {
            selectedInterests.removeAll { $0 == ConfigService.shared.interestsArray[indexPath.row].id }
        }
    }
}
