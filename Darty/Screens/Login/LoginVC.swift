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
import Firebase
import AVFoundation
import SPAlert

final class LoginVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let socialButtonSize: CGFloat = 56
        static let textFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
        static let dartyLogoTextWidth: CGFloat = 82
    }

    // MARK: - UI Elements
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo.text"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let signInButton: DButton = {
        let button = DButton(title: "Войти")
        button.backgroundColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    private let continueWithSocLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.textFont
        label.text = "Или продолжить с учетной записью"
        label.textColor = .white
        return label
    }()
    
    private let googleButton: SocialButton = {
        let button = SocialButton(social: .google)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.socialButtonSize / 2
        button.addTarget(self, action: #selector(googleLoginAction(_:)), for: .touchUpInside)
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

    private var videoPlayer: AVPlayer? {
        return self.videoPlayerLayer?.player
    }

    private let videoView = UIView()
    private let topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#5D011B")
        return view
    }()

    private lazy var videoPlayerLayer: AVPlayerLayer? = {
        guard let videoPath = videoPath else {
            return nil
        }
        let url = URL(fileURLWithPath: videoPath)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        videoView.layer.addSublayer(playerLayer)
        return playerLayer
    }()

    // MARK: - Properties
    private let videoPath = Bundle.main.path(forResource: "MainAnimation", ofType:"mp4")
    private var isLongPressOnScreen = false

    // MARK: - Delegates
    weak var coordinator: AuthCoordinator?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        videoPlayer?.play()
        let longPressGestureRegonizer = UILongPressGestureRecognizer(target: self, action: #selector(panOnScreen(_:)))
        longPressGestureRegonizer.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPressGestureRegonizer)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayerLayer?.player?.currentItem, queue: nil) { notification in
            guard self.isLongPressOnScreen else { return }
            self.replayView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard videoPlayerLayer?.frame != videoView.bounds else { return }
        videoPlayerLayer?.frame = videoView.bounds
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = UIColor(hexString: "#4A0217")
        view.addSubview(topBackgroundView)
        view.addSubview(videoView)
        view.addSubview(signInButton)
        view.addSubview(dartyLogo)
        view.addSubview(continueWithSocLabel)
        view.addSubview(googleButton)
        view.addSubview(appleButton)
        view.addSubview(facebookButton)
    }
    
    // MARK: - Handlers
    @objc private func panOnScreen(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isLongPressOnScreen = true
            replayView()
        case .ended:
            isLongPressOnScreen = false
            rewindVideo()
        default:
            break
        }
    }

    private func replayView() {
        self.videoPlayer?.seek(to: CMTime.zero)
        self.videoPlayer?.play()
    }

    private func rewindVideo() {
        videoPlayer?.rate = -1.0
        videoPlayer?.play()
    }

    @objc private func signInAction() {
        coordinator?.signIn()
    }

    private func startSetupProfile(for user: User) {
        SPAlert.present(
            title: "Успешно",
            message: "Осталось заполнить профиль",
            preset: .custom(UIImage(.face.smiling)),
            haptic: .success
        ) {
            self.view.isUserInteractionEnabled = true
            self.coordinator?.startSetupProfile(for: user)
        }
    }

    private func didSuccessfullLogin(with user: UserModel) {
        SPAlert.present(
            title: "Успешно",
            message: "Вы авторизованы",
            preset: .custom(UIImage(.face.smiling)),
            haptic: .success
        ) {
            self.view.isUserInteractionEnabled = true
            self.coordinator?.changeToMainFlow(with: user)
        }
    }

    private func login(with provider: AuthProviderType, _ sender: SocialButton) {
        view.isUserInteractionEnabled = false
        AuthService.shared.login(with: provider, viewController: self, authAlertDelegate: self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    FirestoreService.shared.getUserData(user: user) { (result) in
                        sender.hideLoading()
                        switch result {
                        case .success(let user):
                            self?.didSuccessfullLogin(with: user)
                        case .failure:
                            self?.startSetupProfile(for: user)
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
}

extension LoginVC {
    // MARK: - Google sign in
    @objc private func googleLoginAction(_ sender: SocialButton) {
        login(with: .google, sender)
    }

    // MARK: Facebook SDK
    @objc private func facebookLoginAction(_ sender: SocialButton) {
        login(with: .facebook, sender)
    }

    // MARK: - Apple Login
    @objc private func appleLoginAction(_ sender: SocialButton) {
        login(with: .apple, sender)
    }
}

// MARK: - Setup constraints
extension LoginVC {
    private func setupConstraints() {
        topBackgroundView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }

        NSLayoutConstraint.activate([
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.heightAnchor.constraint(equalToConstant: UIButton.defaultButtonHeight),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150)
        ])

        videoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(signInButton.snp.bottom).inset(UIButton.defaultButtonHeight / 2)
        }

        dartyLogo.snp.makeConstraints { make in
            make.top.equalTo(videoView.snp.top).offset(21)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.dartyLogoTextWidth)
        }

        NSLayoutConstraint.activate([
            appleButton.heightAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            appleButton.widthAnchor.constraint(equalToConstant: Constants.socialButtonSize),
            appleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
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
            continueWithSocLabel.bottomAnchor.constraint(equalTo: appleButton.topAnchor, constant: -20),
            continueWithSocLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

extension LoginVC: AuthAlertDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
