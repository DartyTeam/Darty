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
        return imageView
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(title: "Sign In", color: .blue)
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    private let continueWithSocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "Or continue with social network account"
        label.textColor = .white
        return label
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "google.login"), for: .normal)
        button.addTarget(self, action: #selector(googleLoginAction), for: .touchUpInside)
        return button
    }()
    
    private let appleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "apple.login"), for: .normal)
        button.addTarget(self, action: #selector(appleLoginAction), for: .touchUpInside)
        return button
    }()
    
    private let facebookButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "facebook.login"), for: .normal)
        button.addTarget(self, action: #selector(facebookLoginAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupViews()
        setupConstraints()
    }
    
    private func addBackground() {
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "login.background")
        
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        view.addSubview(imageViewBackground)
        view.sendSubviewToBack(imageViewBackground)
    }
    
    private func setupViews() {
        addBackground()
        
        view.addSubview(signInButton)
        view.addSubview(dartyLogo)
        view.addSubview(continueWithSocLabel)
        view.addSubview(googleButton)
        view.addSubview(appleButton)
        view.addSubview(facebookButton)
    }
    
    private func setupConstraints() {
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 300),
            signInButton.heightAnchor.constraint(equalToConstant: 44),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -183)
        ])
        
        dartyLogo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dartyLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            dartyLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            googleButton.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor),
            googleButton.trailingAnchor.constraint(equalTo: appleButton.leadingAnchor, constant: -44)
        ])
        
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            facebookButton.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor),
            facebookButton.leadingAnchor.constraint(equalTo: appleButton.trailingAnchor, constant: 44)
        ])
        
        continueWithSocLabel.translatesAutoresizingMaskIntoConstraints = false
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
                            let setupPrifileVC = SetupProfileVC(currentUser: user)
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
                            let setupPrifileVC = SetupProfileVC(currentUser: user)
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
