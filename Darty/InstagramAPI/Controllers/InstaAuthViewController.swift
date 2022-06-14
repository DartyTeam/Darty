//
//  InstaAuthViewController.swift
//  Darty
//
//  Created by Руслан Садыков on 11.09.2021.
//

import WebKit

protocol InstaAuthDelegate {
    func didGetUserData(_ instaUser: InstagramTestUser)
}

class InstaAuthViewController: BaseController, WKNavigationDelegate {
    
    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    // MARK: - Properties
    var instagramApi: InstagramApi?
    var testUserData: InstagramTestUser?
    var delegate: InstaAuthDelegate?
    
    // MARK: - Init
    init(instagramApi: InstagramApi) {
        self.instagramApi = instagramApi
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instagramApi?.authorizeApp { (url) in
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: url!))
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        self.instagramApi?.getTestUserIDAndToken(request: request) { [weak self] (instagramTestUser) in
            self?.testUserData = instagramTestUser
            DispatchQueue.main.async {
                self?.dismissViewController()
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func dismissViewController() {
        self.dismiss(animated: true) {
            if let testUserData = self.testUserData {
                self.delegate?.didGetUserData(testUserData)
            }
        }
    }
}
