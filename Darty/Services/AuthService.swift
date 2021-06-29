//
//  AuthService.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class AuthService {
    
    let userDefaults = UserDefaults.standard
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    
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
        
        guard let auth = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(result.user))
        }
    }
    
    func facebookLogin(error: Error!, completion: @escaping (Result<User, Error>) -> Void) {
                
//        logIn(permissions: ["public_profile", "email"], from: self, handler: { result, error in
//            if error != nil {
//                print("ERROR: Trying to get login results")
//            } else if result?.isCancelled != nil {
//                print("The token is \(result?.token?.tokenString ?? "")")
//                if result?.token?.tokenString != nil {
//                    print("Logged in")
//                    self.getUserProfile(token: result?.token, userId: result?.token?.userID)
//                } else {
//                    print("Cancelled")
//                }
//            }
//        })
    
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
