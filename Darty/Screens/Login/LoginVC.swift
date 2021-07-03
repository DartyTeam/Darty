//
//  LoginVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth

final class LoginVC: UIViewController {
    
    // MARK: - UI Elements
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo.big"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(title: "Sign In")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    private let continueWithSocLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .sfProRounded(ofSize: 16, weight: .semibold)
        label.text = "Or continue with social network account"
        label.textColor = .white
        return label
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "google.login"), for: .normal)
        button.addTarget(self, action: #selector(googleLoginAction), for: .touchUpInside)
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    private let appleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "apple.login"), for: .normal)
        button.addTarget(self, action: #selector(appleLoginAction), for: .touchUpInside)
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    private let facebookButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "facebook.login"), for: .normal)
        button.addTarget(self, action: #selector(facebookLoginAction), for: .touchUpInside)
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupViews()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let welcomeVC = WelcomeVC()
//        welcomeVC.modalPresentationStyle = .overFullScreen
//        present(welcomeVC, animated: true, completion: nil)
    }
    
    private func setupViews() {
        if let image = UIImage(named: "login.background") {
            addBackground(image)
        }
       
        view.addSubview(signInButton)
        view.addSubview(dartyLogo)
        view.addSubview(continueWithSocLabel)
        view.addSubview(googleButton)
        view.addSubview(appleButton)
        view.addSubview(facebookButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -183)
        ])
        
        NSLayoutConstraint.activate([
            dartyLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            dartyLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            appleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            googleButton.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor),
            googleButton.trailingAnchor.constraint(equalTo: appleButton.leadingAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            facebookButton.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor),
            facebookButton.leadingAnchor.constraint(equalTo: appleButton.trailingAnchor, constant: 50)
        ])
        
        NSLayoutConstraint.activate([
            continueWithSocLabel.bottomAnchor.constraint(equalTo: appleButton.topAnchor, constant: -32),
            continueWithSocLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Handlers
    @objc private func signInAction() {
        
    }
    
    @objc private func appleLoginAction() {
        
    }
}

// MARK: - GIDSignInDelegate
extension LoginVC: GIDSignInDelegate {
    
    @objc private func googleLoginAction() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        AuthService.shared.googleLogin(user: user, error: error) { [weak self] (result) in
            switch result {
            
            case .success(let user):
                
                FirestoreService.shared.getUserData(user: user) { (result) in
                    switch result {
                    
                    case .success(let user):
                        
                        UIApplication.getTopViewController()?.showAlert(title: "Успешно", message: "Вы авторизованы", completion: {
                            let tabBarController = TabBarController(currentUser: user)
                            self?.navigationController?.pushViewController(tabBarController, animated: false)
                        })
                    case .failure(_):
                        
                        self?.showAlert(title: "Успешно", message: "Осталось заполнить профиль") {
                            let setupPrifileVC = NameSetupProfileVC(currentUser: user)
                            self?.navigationController?.pushViewController(setupPrifileVC, animated: true)
                        }
                    }
                }
            case .failure(let error):
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}

// MARK: Facebook SDK
extension LoginVC {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
    }
    
    @objc private func facebookLoginAction() {
                
        if let token = AccessToken.current, !token.isExpired {
            facebookLoginFirebase()
        } else {
            
            let loginManager = LoginManager()
            loginManager.logIn(permissions: [.publicProfile, .email], viewController: self, completion: { [weak self] loginResult in
                switch loginResult {
                case .failed(let error):
                    print("\(error)")
                case .cancelled:
                    print("cancelled fb login")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("\(grantedPermissions) \(declinedPermissions)")
                    self?.facebookLoginFirebase()
                }
            })
        }
    }
    
    private func facebookLoginFirebase() {
        AuthService.shared.facebookLogin(error: Error?.self as? Error) { [weak self] result in
            switch result {
            
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { (result) in
                    switch result {
                    
                    case .success(let user):
                        
                        UIApplication.getTopViewController()?.showAlert(title: "Успешно", message: "Вы авторизованы", completion: {
                            let tabBarController = TabBarController(currentUser: user)
                            self?.navigationController?.pushViewController(tabBarController, animated: false)
                        })
                    case .failure(_):
                                        
                        self?.showAlert(title: "Успешно", message: "Осталось заполнить профиль") {
                            let setupPrifileVC = NameSetupProfileVC(currentUser: user)
                            self?.navigationController?.pushViewController(setupPrifileVC, animated: true)
                        }
                    }
                }
            case .failure(let error):
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}
