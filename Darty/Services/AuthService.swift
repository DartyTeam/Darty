//
//  AuthService.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import SPAlert

enum AuthProviderId: String {
    case phone = "phone"
    case facebook = "facebook.com"
    case google = "google.com"
    case apple = "apple.com"
}

enum AuthProviderType {
    case phone(verificationCode: String)
    case facebook
    case google
    case apple
}

protocol AuthAlertDelegate: AnyObject {
    func show(alert: UIAlertController)
}

final class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let auth = Auth.auth()

    var currentUser: UserModel! {
        didSet {
            NotificationCenter.default.post(GlobalConstants.changedUserDataNotification)
        }
    }

    func login(with authProvider: AuthProviderType,
               viewController: UIViewController,
               authAlertDelegate: AuthAlertDelegate,
               completion: @escaping (Result<User, Error>) -> Void) {
        var credential: AuthCredential?
        let dg = DispatchGroup()
        switch authProvider {
        case let .phone(verificationCode):
            dg.enter()
            getPhoneLoginCredential(with: verificationCode) { result in
                switch result {
                case .success(let phoneCredential):
                    credential = phoneCredential
                    dg.leave()
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        case .facebook:
            dg.enter()
            getFacebookLoginCredential(viewController: viewController) { result in
                switch result {
                case .success(let fbCredential):
                    credential = fbCredential
                    dg.leave()
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        case .google:
            print("asdijasodiajdisoadjaiosdjaiosdjaiosd")
            dg.enter()
            getGoogleLoginCredential(viewController: viewController) { result in
                switch result {
                case .success(let googleCredential):
                    credential = googleCredential
                    dg.leave()
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        case .apple:
            return
        }

        dg.notify(queue: .main) {
            guard let credential = credential else {
                completion(.failure(AuthError.noUserData))
                return
            }

            self.login(with: credential, authAlertDelegate: authAlertDelegate) { result in
                switch result  {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getGoogleLoginCredential(viewController: UIViewController,
                                  completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        print("aisdjasoidjaiosjd")
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let auth = user?.authentication, let authIdToken = auth.idToken else {
                completion(.failure(AuthError.noUserData))
                return
            }
            print("igu7t78u")


            let credential = GoogleAuthProvider.credential(withIDToken: authIdToken, accessToken: auth.accessToken)
            completion(.success(credential))
        }
    }
    
    private func getFacebookLoginCredential(viewController: UIViewController,
                                            completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        let dg = DispatchGroup()
        if let token = AccessToken.current, !token.isExpired {
            dg.enter()
            dg.leave()
        } else {
            let loginManager = LoginManager()
            dg.enter()
            loginManager.logIn(
                permissions: [.publicProfile, .userBirthday, .userGender],
                viewController: viewController,
                completion: { loginResult in
                switch loginResult {
                case .failed(let error):
                    print("ERROR_LOG Error FB login: \(error)")
                    completion(.failure(error))
                    return
                case .cancelled:
                    print("Cancelled FB login")
                    completion(.failure(AuthError.userCanceledAuth))
                    return
                case let .success(grantedPermissions, declinedPermissions, accessToken):
                    print("FB Success Login with \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                    dg.leave()
                }
            })
        }

        dg.notify(queue: .main) {
            let accessToken = AccessToken.current
            guard let accessTokenString = accessToken?.tokenString else {
                completion(.failure(AuthError.noUserData))
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            completion(.success(credential))
        }
    }

    func getPhoneLoginCredential(with verificationCode: String,
                                 completion: @escaping (Result<PhoneAuthCredential, Error>) -> Void) {
        guard let verificationID = UserDefaults.standard.phoneAuthVerificationID else {
            completion(.failure(AuthError.noSavedVerificationID))
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        completion(.success(credential))
    }

    func deleteAccount(viewController: UIViewController,
                       uiDelegate: AuthUIDelegate,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        let spinnerView = SPAlertView(title: "Удаление...", preset: .spinner)
        reauthentification(viewController: viewController, uiDelegate: uiDelegate) { result in
            switch result {
            case .success(let string):
                spinnerView.present()
                FirestoreService.shared.deleteCurrentUser { result in
                    switch result {
                    case .success:
                        let user = self.auth.currentUser
                        user?.delete { error in
                            spinnerView.dismiss()
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    case .failure(let error):
                        spinnerView.dismiss()
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                spinnerView.dismiss()
                completion(.failure(error))
            }
        }
    }

    private func reauthentification(viewController: UIViewController,
                                    uiDelegate: AuthUIDelegate,
                                    completion: @escaping (Result<String?, Error>) -> Void) {

        // Prompt the user to re-provide their sign-in credentials
        guard let user = auth.currentUser, let userProviderId = user.providerData.first?.providerID else {
            completion(.failure(AuthError.noUserData))
            return
        }

        var credential: AuthCredential?
        let providerId = AuthProviderId(rawValue: userProviderId)
        let dg = DispatchGroup()
        switch providerId {
        case .apple:
            break
        case .facebook:
            dg.enter()
            getFacebookLoginCredential(viewController: viewController) { result in
                switch result {
                case .success(let fbCredential):
                    credential = fbCredential
                    dg.leave()
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        case .google:
            print("asdijasdiajsdioasjdioasodasd")
            dg.enter()
            getGoogleLoginCredential(viewController: viewController) { result in
                switch result {
                case .success(let googleCredential):
                    print("asd89jasd89ashjd78asd: ", googleCredential)
                    credential = googleCredential
                    dg.leave()
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        case .phone:
            guard let phoneNumber = user.phoneNumber else {
                completion(.failure(AuthError.noUserData))
                return
            }
            self.sendSmsCodeFor(phoneNumber: phoneNumber, uiDelegate: uiDelegate) { result in
                switch result {
                case .success:
                    completion(.success("Смс с кодом было отправлено. Введите код из смс"))
                case .failure(let error):
                    completion(.failure(error))
                }
                return
            }
        default:
            completion(.failure(AuthError.noSavedCredential))
            return
        }

        dg.notify(queue: .main) {
            print("uhbgkbhkhguyikbikihjky")
            guard let credential = credential else {
                completion(.failure(AuthError.noUserData))
                return
            }

            print("asiodjasoidjasidjasdiadaodjasjdaoisd")

            user.reauthenticate(with: credential, completion: { authDataResult, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success((nil)))
                }
            })
        }
    }

    func reauthWith(phoneVerificationCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let verificationID = UserDefaults.standard.phoneAuthVerificationID else {
            completion(.failure(AuthError.noSavedVerificationID))
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: phoneVerificationCode
        )
        guard let user = auth.currentUser else {
            completion(.failure(AuthError.noUserData))
            return
        }
        user.reauthenticate(with: credential, completion: { authDataResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        })
    }

    func sendSmsCodeFor(phoneNumber: String, uiDelegate: AuthUIDelegate, completion: @escaping (Result<Void, Error>) -> Void) {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: uiDelegate) { verificationID, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                UserDefaults.standard.phoneAuthVerificationID = verificationID
                completion(.success(()))
            }
    }

    func updatePhoneNumber(verificationCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        getPhoneLoginCredential(with: verificationCode) { result in
            switch result {
            case .success(let phoneCredential):
                self.auth.currentUser?.updatePhoneNumber(phoneCredential, completion: { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func login(with credential: AuthCredential, authAlertDelegate: AuthAlertDelegate, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let authError = error as NSError
                if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError
                        .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                    let alertVC = UIAlertController(title: nil, message: "Select factor to sign in\n\(displayNameString)", preferredStyle: .alert)
                    alertVC.addTextField { (textField) in
                        textField.placeholder = "Display name"
                    }
                    let okAction = UIAlertAction(title: "ОК", style: .default) { _ in
                        let displayNameTextField = alertVC.textFields![0] as UITextField
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                            if displayNameTextField.text == tmpFactorInfo.displayName {
                                selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                            }
                        }
                        PhoneAuthProvider.provider()
                            .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                               multiFactorSession: resolver
                                                .session) { verificationID, error in
                                if let error = error {
                                    print("Multi factor start sign in failed. Error: \(error.localizedDescription)")
                                    completion(.failure(error))
                                    return
                                } else {
                                    let alertVC = UIAlertController(
                                        title: nil,
                                        message: "Verification code for \(selectedHint?.displayName ?? "")",
                                        preferredStyle: .alert
                                    )
                                    alertVC.addTextField { (textField) in
                                        textField.placeholder = "Verification code"
                                    }
                                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                                        let verificationCode = (alertVC.textFields![0] as UITextField).text
                                        let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                            .credential(withVerificationID: verificationID!,
                                                        verificationCode: verificationCode!)
                                        let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                            .assertion(with: credential!)
                                        resolver.resolveSignIn(with: assertion!) { authResult, error in
                                            if let error = error {
                                                print("Multi factor finanlize sign in failed. Error: \(error.localizedDescription)")
                                                completion(.failure(error))
                                                return
                                            } else {
#warning("Не понятно почему тут это")
                                                //                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        }
                                    }
                                    alertVC.addAction(okAction)
                                    authAlertDelegate.show(alert: alertVC)
                                }
                            }
                    }
                    alertVC.addAction(okAction)
                    authAlertDelegate.show(alert: alertVC)
                } else {
                    completion(.failure(error))
                    return
                }
                completion(.failure(authError))
                return
            }
            if let user = authResult?.user {
                completion(.success(user))
            } else {
                completion(.failure(AuthError.noUserData))
            }
        }
    }
}

//    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
//        auth.signIn(withEmail: email!, password: password!) { (result, error) in
//            guard let _ = email, let _ = password else {
//                completion(.failure(Errors.notFilled))
//                return
//            }
//
//            guard let result = result else {
//                completion(.failure(error!))
//                return
//            }
//            self.credential = result.credential
//
//            completion(.success(result.user))
//        }
//    }
