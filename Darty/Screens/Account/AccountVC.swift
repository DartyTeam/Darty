//
//  AccountVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseAuth

enum ThemeChangeMode {
    case manual
    case auto
}

final class AccountVC: UIViewController {

    // MARK: - UI Elements
    private lazy var logoutButton: UIButton = {
        let button = UIButton(title: "Выход")
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(logoutAction), for: .touchDown)
        return button
    }()
    
    private let iconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 14, weight: .bold))
    private lazy var handIcon = UIImage(systemName: "hand.point.up.left.fill", withConfiguration: iconConfig)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
    private lazy var autoIcon = UIImage(systemName: "a.circle.fill", withConfiguration: iconConfig)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
    
    private lazy var darkModeButton: UIButton = {
        let button = UIButton(title: "Темный режим")
        button.backgroundColor = .black.withAlphaComponent(0.75)
        button.setImage(handIcon, for: UIControl.State())
        button.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8941176471, alpha: 1)
        button.layer.cornerRadius = 16
        button.tintColor = .systemOrange
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(themeSwitchAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var themeMode: ThemeChangeMode = .auto
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(logoutButton)
        view.addSubview(darkModeButton)
    }
    
    private func setupConstraints() {
        logoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            make.height.equalTo(50)
        }
        
        darkModeButton.snp.makeConstraints { make in
            make.width.equalTo(256)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Handlers
    @objc private func logoutAction() {
        
        let ac = UIAlertController(title: nil, message: "Вы уверены что хотите выйти?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let navController = UINavigationController(rootViewController: LoginVC())
                navController.setNavigationBarHidden(true, animated: false)
                UIApplication.shared.keyWindow?.rootViewController = navController
            } catch {
                print("Error sogning out: \(error.localizedDescription)")
            }
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func themeSwitchAction() {
        
        switch themeMode {
        
        case .manual:
            darkModeButton.setImage(autoIcon, for: UIControl.State())
            themeMode = .auto
            overrideUserInterfaceStyle = .dark
        case .auto:
            darkModeButton.setImage(handIcon, for: UIControl.State())
            themeMode = .manual
            overrideUserInterfaceStyle = .unspecified
        }
    }
}
