//
//  InstagramAPI.swift
//  Darty
//
//  Created by Руслан Садыков on 11.09.2021.
//

import Foundation

private enum BaseURL: String {
    case displayApi = "https://api.instagram.com/"
    case graphApi = "https://graph.instagram.com/"
}

private enum Method: String {
    case authorize = "oauth/authorize"
    case accessToken = "oauth/access_token"
}

class InstagramApi {
    static let shared = InstagramApi()
    private let instagramAppID = "380440183639897"
    private let redirectURIURLEncoded = "https%3A%2F%2Fru5c55an.github.io/DartySite%2F"
    private let redirectURI = "https://ru5c55an.github.io/DartySite/"
    private let appSecret = "da71726110cc2372b98d72472868d6d7"
    private let boundary = "boundary=\(NSUUID().uuidString)"
    private init () {}
    
    func authorizeApp(completion: @escaping (_ url: URL?) -> Void ) {
        let urlString = "\(BaseURL.displayApi.rawValue)\(Method.authorize.rawValue)?client_id=\(instagramAppID)&redirect_uri=\(redirectURIURLEncoded)&scope=user_profile,user_media&response_type=code"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                print("Auth insta app response: ", response)
                completion(response.url)
            }
        })
        task.resume()
    }
    
    private func getTokenFromCallbackURL(request: URLRequest) -> String? {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.starts(with: "\(redirectURI)?code=") {
            print("Response uri: ", requestURLString)
            if let range = requestURLString.range(of: "\(redirectURI)?code=") {
                return String(requestURLString[range.upperBound...].dropLast(2))
            }
        }
        return nil
    }
    
    private func getFormBody(_ parameters: [[String : String]], _ boundary: String) -> Data {
        var body = ""
        let error: NSError? = nil
        for param in parameters {
            let paramName = param["name"]!
            body += " — \(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
                var fileContent: String = ""
                do {
                    fileContent = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)
                } catch {
                    print(error)
                }
                if (error != nil) {
                    print(error!)
                }
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                body += fileContent
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        return body.data(using: .utf8)!
    }
    
    func getTestUserIDAndToken(request: URLRequest, completion: @escaping (InstagramTestUser) -> Void){
        guard let authToken = getTokenFromCallbackURL(request: request) else {
            return
        }
        print("asdijoajosdjois: ", boundary)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let data : Data = "client_id=\(instagramAppID)&client_secret=\(appSecret)&grant_type=authorization_code&redirect_uri=\(redirectURI)&code=\(authToken)".data(using: .utf8)!
        var request = URLRequest(url: URL(string: BaseURL.displayApi.rawValue + Method.accessToken.rawValue)!)
        print("asdjoajosidjasdoiaosijd: ", BaseURL.displayApi.rawValue + Method.accessToken.rawValue)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = data
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            print("asiodjaoisdaosidj: ", response)
            if let error = error {
                print("ERROR_LOG Error in getTestUserIDAndToken requst: ", error)
            } else {
                do {
                    let jsonData = try JSONDecoder().decode(InstagramTestUser.self, from: data!)
                    print(jsonData)
                    completion(jsonData)
                } catch let error as NSError {
                    print(error)
                }
            }
        })
        dataTask.resume()
    }
    
    func getInstagramUser(testUserData: InstagramTestUser, completion: @escaping (InstagramUser) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue)\(testUserData.userId)?fields=id,username&access_token=\(testUserData.accessToken)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            do {
                let jsonData = try JSONDecoder().decode(InstagramUser.self, from: data!)
                completion(jsonData)
            } catch let error as NSError {
                print(error)
            }
        })
        dataTask.resume()
    }
    
    func getMediaData(accessToken: String, completion: @escaping (InstaFeed) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue)me/media?fields=id,caption,media_url,media_type,username,timestamp&access_token=\(accessToken)"
        print("asdojasodjasdi: ", urlString)
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                print(response)
            }
            do {
                let jsonData = try JSONDecoder().decode(InstaFeed.self, from: data!)
                print(jsonData)
                completion(jsonData)
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    func getMediaData(for userId: String, accessToken: String, completion: @escaping (InstaFeed) -> Void) {
//        https://api.instagram.com/v1/users/{user-id}/media/recent?access_token={access-token}
        let urlString = "\(BaseURL.graphApi.rawValue)\(userId)/media?fields=id,caption,media_url,media_type,username,timestamp&access_token=\(accessToken)"
        print("asdojasodjasdi: ", urlString)
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                print(response)
            }
            do {
                let jsonData = try JSONDecoder().decode(InstaFeed.self, from: data!)
                print(jsonData)
                completion(jsonData)
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    func getMedia(by id: String, accessToken: String, completion: @escaping (InstagramMedia) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue + id)?fields=id,media_type,media_url,username,timestamp&access_token=\(accessToken)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                print(response)
            }
            do {
                let jsonData = try JSONDecoder().decode(InstagramMedia.self, from: data!)
                print(jsonData)
                completion(jsonData)
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    func getLongTermAccessTiken(accessToken: String, completion: @escaping (InstaLongTermAccessToken) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue)access_token?grant_type=ig_exchange_token&client_secret=\(appSecret)&access_token=\(accessToken)"
        print("asidjaosidjsajodioaid: ", urlString)
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            do {
                let jsonData = try JSONDecoder().decode(InstaLongTermAccessToken.self, from: data!)
                completion(jsonData)
            } catch let error as NSError {
                print(error)
            }
        })
        dataTask.resume()
    }
}
