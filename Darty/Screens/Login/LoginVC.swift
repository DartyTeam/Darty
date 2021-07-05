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

private enum Constants {
    static let socialButtonSize: CGFloat = 50
    static let textFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
}

final class LoginVC: UIViewController {
    
    // MARK: - UI Elements
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo.text"))
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
        label.font = Constants.textFont
        label.text = "Or continue with social network account"
        label.textColor = .white
        return label
    }()
    
    private let googleButton: SocialButton = {
        let button = SocialButton(social: .google)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.socialButtonSize / 2
        button.addTarget(self, action: #selector(googleLoginAction), for: .touchUpInside)
        return button
    }()
    
    private let appleButton: SocialButton = {
        let button = SocialButton(social: .apple)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.socialButtonSize / 2
        button.addTarget(self, action: #selector(appleLoginAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private let facebookButton: SocialButton = {
        let button = SocialButton(social: .facebook)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.socialButtonSize / 2
        button.addTarget(self, action: #selector(facebookLoginAction(_:)), for: .touchUpInside)
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
        
        if !(UserDefaults.standard.isPrevLaunched ?? false) {
            let welcomeVC = WelcomeVC()
            welcomeVC.modalPresentationStyle = .popover
            present(welcomeVC, animated: true, completion: nil)
        }
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
            appleButton.heightAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            appleButton.widthAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            appleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            googleButton.heightAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            googleButton.widthAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            googleButton.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor),
            googleButton.trailingAnchor.constraint(equalTo: appleButton.leadingAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            facebookButton.heightAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            facebookButton.widthAnchor.constraint(equalToConstant: Constants.socialButtonSize),
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
        let signInVC = SignInVC()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    @objc private func appleLoginAction(_ sender: SocialButton) {
        
    }
}

// MARK: - GIDSignInDelegate
extension LoginVC: GIDSignInDelegate {
    
    @objc private func googleLoginAction() {
        view.isUserInteractionEnabled = false
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
                            self?.googleButton.hideLoading()
                            self?.view.isUserInteractionEnabled = true
                            let tabBarController = TabBarController(currentUser: user)
                            self?.navigationController?.pushViewController(tabBarController, animated: false)
                        })
                    case .failure(_):
                        
                        self?.showAlert(title: "Успешно", message: "Осталось заполнить профиль") {
                            self?.googleButton.hideLoading()
                            self?.view.isUserInteractionEnabled = true
                            let setupPrifileVC = NameSetupProfileVC(currentUser: user)
                            self?.navigationController?.pushViewController(setupPrifileVC, animated: true)
                        }
                    }
                }
            case .failure(let error):
                self?.googleButton.hideLoading()
                self?.view.isUserInteractionEnabled = true
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
    
    @objc private func facebookLoginAction(_ sender: SocialButton) {
        view.isUserInteractionEnabled = false
        
        if let token = AccessToken.current, !token.isExpired {
            facebookLoginFirebase(sender)
        } else {
            
            let loginManager = LoginManager()
            loginManager.logIn(permissions: [.publicProfile, .email], viewController: self, completion: { [weak self] loginResult in
                switch loginResult {
                case .failed(let error):
                    print("\(error)")
                    sender.hideLoading()
                    self?.view.isUserInteractionEnabled = true
                case .cancelled:
                    print("cancelled fb login")
                    sender.hideLoading()
                    self?.view.isUserInteractionEnabled = true
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("\(grantedPermissions) \(declinedPermissions)")
                    self?.facebookLoginFirebase(sender)
                }
            })
        }
    }
    
    private func facebookLoginFirebase(_ sender: SocialButton) {
        AuthService.shared.facebookLogin(error: Error?.self as? Error) { [weak self] result in
            switch result {
            
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { (result) in
                    switch result {
                    
                    case .success(let user):
                        
                        UIApplication.getTopViewController()?.showAlert(title: "Успешно", message: "Вы авторизованы", completion: {
                            sender.hideLoading()
                            self?.view.isUserInteractionEnabled = true
                            let tabBarController = TabBarController(currentUser: user)
                            self?.navigationController?.pushViewController(tabBarController, animated: false)
                        })
                    case .failure(_):
                                        
                        self?.showAlert(title: "Успешно", message: "Осталось заполнить профиль") {
                            sender.hideLoading()
                            self?.view.isUserInteractionEnabled = true
                            let setupPrifileVC = NameSetupProfileVC(currentUser: user)
                            self?.navigationController?.pushViewController(setupPrifileVC, animated: true)
                        }
                    }
                }
            case .failure(let error):
                sender.hideLoading()
                self?.view.isUserInteractionEnabled = true
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}
