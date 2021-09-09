//
//  AuthService.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Firebase
import GoogleSignIn
import FBSDKLoginKit

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
    
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email!, password: password!) { (result, error) in
            guard let _ = email, let _ = password else {
                completion(.failure(Errors.notFilled))
                return
            }
            
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
    func googleLogin(user: GIDGoogleUser!, error: Error!, completion: @escaping (Result<User, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        let auth = user.authentication
        
        guard let authIdToken = auth.idToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authIdToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
    func facebookLogin(error: Error!, completion: @escaping (Result<User, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        let accessToken = AccessToken.current
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(result.user))
        }
    }
}
