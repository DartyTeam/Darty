//
//  SixthCreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import UIKit
import FirebaseAuth
import SnapKit

final class SixthCreateVC: UIViewController {
    
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
        static let countFont: UIFont? = .sfProDisplay(ofSize: 22, weight: .semibold)
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
        static let countGuestsText = "Кол-во гостей"
        static let minAgeText = "Мин. возраст"
        static let priceText = "Цена за вход"
    }
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let currentUser: UserModel
    private var setuppedParty: SetuppedParty
    
    // MARK: - Lifecycle
    init(currentUser: UserModel, setuppedParty: SetuppedParty) {
        self.currentUser = currentUser
        self.setuppedParty = setuppedParty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupNavBar() {
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        let cancelIconImage = UIImage(systemName: "xmark.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelIconImage, style: .plain, target: self, action: #selector(cancleAction))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        setuppedParty.city = "Санкт Петербург"
        setuppedParty.location = "current"
        
        FirestoreService.shared.savePartyWith(party: setuppedParty) { [weak self] (result) in
            switch result {
            
            case .success(_):
                let alertController = UIAlertController(title: "🎉 Ура! Вечеринка создана. Вы можете найти ее в Мои вечеринки", message: "", preferredStyle: .actionSheet)
                let shareAction = UIAlertAction(title: "Поделиться ссылкой", style: .default) { _ in
                    let items: [Any] = ["This app is my favorite", URL(string: "https://www.apple.com")!]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
                    self?.present(ac, animated: true)
                }
                let goAction = UIAlertAction(title: "Перейти к вечеринке", style: .default) { _ in
                    #warning("Нужно добавить открытие вечеринки и переход в Мои вечеринки")
                }
                
                let doneAction = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                
                alertController.addAction(shareAction)
                alertController.addAction(goAction)
                alertController.addAction(doneAction)
                
                self?.present(alertController, animated: true, completion: nil)
            
            case .failure(let error):
            self?.showAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }
}
    
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Setup constraints
extension SixthCreateVC {
    private func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
    }
}
