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
        
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Готово 􀆅")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        return searchBar
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
        return collectionView
    }()
    
    // MARK: - Properties
    private var isFiltering: Bool {
        return !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchBar.text else { return false }
        return text.isEmpty
    }
    
    private let currentUser: User
    private let setupedUser: SetuppedUser
    
    private let interestsArray = [InterestModel(id: 0, title: "Игры", emoji: "🎮"),
                                  InterestModel(id: 1, title: "Бег", emoji: "🏈"),
                                  InterestModel(id: 2, title: "Музыка", emoji: "🧩"),
                                  InterestModel(id: 3, title: "Пение", emoji: "♦️"),
                                  InterestModel(id: 4, title: "Пианино", emoji: "⛳️"),
                                  InterestModel(id: 5, title: "Скейтбординг", emoji: "⛳️"),
                                  InterestModel(id: 6, title: "Спорт", emoji: "⛳️"),
                                  InterestModel(id: 7, title: "Программирование", emoji: "⛳️"),
                                  InterestModel(id: 8, title: "Путешествия", emoji: "⛳️"),
                                  InterestModel(id: 9, title: "Танцы", emoji: "⛳️")]
    
    private var filteredInterests: [InterestModel] = []
    
    private var selectedInterests = [Int]()
    
    // MARK: - Lifecycle
    init(currentUser: User, setupedUser: SetuppedUser) {
        self.currentUser = currentUser
        self.setupedUser = setupedUser
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
        
        setNavigationBar(withColor: .systemBlue, title: "Изображение")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        if let image = UIImage(named: "image.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.5)) {
            addBackground(image)
        }
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchBar)
        view.addSubview(nextButton)
        view.addSubview(interestsCollectionView)
    }
    
    // MARK: - Handlers
    @objc private func keyboardWillHide(notification: NSNotification) {
//        nextButton.snp.remakeConstraints { make in
//            make.left.right.equalToSuperview().inset(63)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-42)
//            make.height.equalTo(50)
//        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//
//        nextButton.snp.remakeConstraints { make in
//            make.left.right.equalToSuperview().inset(63)
//            make.bottom.equalToSuperview().offset(-keyboardFrame.height - 24)
//            make.height.equalTo(50)
//        }
                
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
                                                sex: setupedUser.sex!,
                                                birthday: setupedUser.birthday!,
                                                interestsList: selectedInterests) { [weak self] (result) in
            switch result {
            
            case .success(let user):
                self?.showAlert(title: "Успешно", message: "Веселитесь!") {
                    let tabBarController = TabBarController(currentUser: user)
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
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
        
        NSLayoutConstraint.activate([
            interestsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 32),
            interestsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            interestsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            interestsCollectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -32)
        ])

    }
}

extension InterestsSetupProfileVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredInterests = interestsArray.filter({ interest in
            interest.title.contains(searchText) ||  interest.emoji.contains(searchText)
        })
        
        interestsCollectionView.reloadData()
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
        return interestsArray.count
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
        
        cell.setupCell(title: interestsArray[indexPath.row].title, emoji: interestsArray[indexPath.row].emoji)
        if selectedInterests.contains(interestsArray[indexPath.row].id) {
            cell.isSelected = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFiltering {
            selectedInterests.append(filteredInterests[indexPath.row].id)
        } else {
            selectedInterests.append(interestsArray[indexPath.row].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isFiltering {
            selectedInterests.removeAll { $0 == filteredInterests[indexPath.row].id }
        } else {
            selectedInterests.removeAll { $0 == interestsArray[indexPath.row].id }
        }
    }
}
