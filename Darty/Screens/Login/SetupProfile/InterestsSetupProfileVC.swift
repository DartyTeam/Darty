//
//  InterestsSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 05.07.2021.
//

import UIKit
import FirebaseAuth

struct InterestModel {
    let id: Int
    let title: String
    let emoji: String
}

final class InterestsSetupProfileVC: UIViewController {
        
    // MARK: - Constants
    private enum Constants {
        static let interestsCollectionViewInsets = UIEdgeInsets(top: 32, left: 20, bottom: 128, right: 20)
    }
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Готово 􀆅")
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
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Properties
    private var isFiltering: Bool {
        return !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private let currentUser: User
    private let setupedUser: SetuppedUser
    
    private var filteredInterests: [InterestModel] = []
    
    private var selectedInterests = [Int]()
    
    // MARK: - Lifecycle
    init(currentUser: User, setuppedUser: SetuppedUser) {
        self.currentUser = currentUser
        self.setupedUser = setuppedUser
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setNavigationBar(withColor: .systemBlue, title: "Интересы", withClear: false)
        setupSearchBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(interestsCollectionView)
        view.addSubview(nextButton)
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
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        interestsCollectionView.contentInset = Constants.interestsCollectionViewInsets
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        interestsCollectionView.contentInset = UIEdgeInsets(top:  Constants.interestsCollectionViewInsets.top, left:  Constants.interestsCollectionViewInsets.left, bottom: keyboardFrame.size.height, right:  Constants.interestsCollectionViewInsets.right)
        
        nextButton.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
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
         
        FirestoreService.shared.saveProfileWith(id: currentUser.uid,
                                                phone: currentUser.phoneNumber ?? "",
                                                username: setupedUser.name,
                                                avatarImage: setupedUser.image,
                                                description: setupedUser.description,
                                                sex: setupedUser.sex,
                                                birthday: setupedUser.birthday!,
                                                interestsList: selectedInterests,
                                                city: setupedUser.city!,
                                                country: setupedUser.country!) { [weak self] (result) in
            switch result {
            
            case .success(let user):
                self?.showAlert(title: "Успешно", message: "Веселитесь!") {
                    AuthService.shared.currentUser = user
                    let tabBarController = TabBarController()
                    tabBarController.modalPresentationStyle = .fullScreen
                    self?.present(tabBarController, animated: true, completion: nil)
                }
            case .failure(let error):
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - Setup constraints
extension InterestsSetupProfileVC {
    
    private func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        interestsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension InterestsSetupProfileVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    private func filterContentForSearchText(_ searchText: String) {
        filteredInterests = GlobalConstants.interestsArray.filter({ interest in
            interest.title.lowercased().contains(searchText.lowercased()) || interest.emoji.contains(searchText)
        })
        
        interestsCollectionView.reloadSections([0])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension InterestsSetupProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredInterests.count
        }
        return GlobalConstants.interestsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestCell.reuseIdentifier, for: indexPath) as! InterestCell
        
       
        if isFiltering {
            cell.setupCell(title: filteredInterests[indexPath.row].title, emoji: filteredInterests[indexPath.row].emoji)
            if selectedInterests.contains(filteredInterests[indexPath.row].id) {
                cell.isSelected = true
            }
            return cell
        }
        
        cell.setupCell(title: GlobalConstants.interestsArray[indexPath.row].title, emoji: GlobalConstants.interestsArray[indexPath.row].emoji)
        if selectedInterests.contains(GlobalConstants.interestsArray[indexPath.row].id) {
            cell.isSelected = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFiltering {
            selectedInterests.append(filteredInterests[indexPath.row].id)
        } else {
            selectedInterests.append(GlobalConstants.interestsArray[indexPath.row].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isFiltering {
            selectedInterests.removeAll { $0 == filteredInterests[indexPath.row].id }
        } else {
            selectedInterests.removeAll { $0 == GlobalConstants.interestsArray[indexPath.row].id }
        }
    }
}
