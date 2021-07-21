//
//  AccountVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseAuth

final class AccountVC: UIViewController {

    // MARK: - UI Elements
    private lazy var logoutButton: UIButton = {
        let button = UIButton(title: "Выход")
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(logoutAction), for: .touchDown)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemIndigo
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        logoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Handlers
    @objc private func logoutAction() {
        
        let ac = UIAlertController(title: nil, message: "Вы уверены что хотите выйти?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.keyWindow?.rootViewController = LoginVC()
            } catch {
                print("Error sogning out: \(error.localizedDescription)")
            }
        }))
        
        present(ac, animated: true, completion: nil)
    }
}

