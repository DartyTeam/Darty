//
//  AccountVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseAuth
import StoreKit

enum ThemeChangeMode {
    case manual
    case auto
}

final class AccountVC: BaseController {

    // MARK: - Constants
    private enum Constants {
        static let navigationBarButtonsFont: UIFont? = .sfProRounded(ofSize: 14, weight: .bold)
        static let navigationBarButtonsSize: CGFloat = 36
        
        static let userAvatarSize: CGFloat = 128
        static let nameFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
        static let cityFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .medium)
        static let ageFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
        static let ratingFont: UIFont? = .sfProRounded(ofSize: 18, weight: .semibold)

        static let subscribeDartyLogoSize: CGFloat = 28
        static let subscribeNameLabelFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
        static let subscribeNameLabelText = "Darty Max"
        
        static let subscribeInfoLabelFont: UIFont? = .sfProRounded(ofSize: 14, weight: .medium)
        static let subscribeInfoLabelText = "Используй приложение по максимуму, получай приоритет в выдаче и прочие преимущества..."
        static let subscribeInfoLabelColor: UIColor = .secondaryLabel
        
        static let subscribeExpiredLabelFont: UIFont? = .sfProText(ofSize: 14, weight: .regular)
        static let subscribeExpiredLabelPlaceholder = "Подробнее"
        static let subscribeExpiredLabelTopBottomInsets: CGFloat = 4
        static let subscribeExpiredLabelLeftRightInsets: CGFloat = 8
        
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
        
        static let subscribeButtonsTitleFont: UIFont? = .sfProRounded(ofSize: 12, weight: .medium)
        static let subscribeButtonsTextFont: UIFont? = .sfProDisplay(ofSize: 14, weight: .semibold)
        
        static let buyDartsTitleText = "Дарты: 0"
        static let buyDartsActionText = "Добавить"
        static let donateTitleText = "Донат"
        static let donateActionText = "Отправить"
 
        static let productUrl = URL(string: "https://itunes.apple.com/app/id375380948")!
    }
    
    // MARK: - UI Elements
    private let iconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 14, weight: .bold))
    private lazy var handIcon = UIImage(systemName: "hand.point.up.left.fill", withConfiguration: iconConfig)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
    private lazy var autoIcon = UIImage(systemName: "a.circle.fill", withConfiguration: iconConfig)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["􀋲 Меню", "􀍣 Подписка"])
        segmentedControl.selectedSegmentIndex = 0
        let attr = NSDictionary(object: Constants.segmentFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()

    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()

    private lazy var userAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.userAvatarSize / 2
        imageView.backgroundColor = .systemGray
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openAboutUser(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .title
        label.textColor = Colors.Text.main
        return label
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.snp.makeConstraints { make in
            make.size.equalTo(Constants.navigationBarButtonsSize)
        }
        let configIcon = UIImage.SymbolConfiguration(font: Constants.navigationBarButtonsFont!)
        let shareIcon = UIImage(systemName: "square.and.arrow.up", withConfiguration: configIcon)?.withTintColor(Colors.Elements.element, renderingMode: .alwaysOriginal)
        button.setImage(shareIcon, for: UIControl.State())
        button.layer.cornerRadius = Constants.navigationBarButtonsSize / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(shareAccount), for: .touchUpInside)
        button.backgroundColor = Colors.Backgorunds.plate
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.snp.makeConstraints { make in
            make.size.equalTo(Constants.navigationBarButtonsSize)
        }
        let configIcon = UIImage.SymbolConfiguration(font: Constants.navigationBarButtonsFont!)
        let editIcon = UIImage(systemName: "pencil", withConfiguration: configIcon)?.withTintColor(Colors.Elements.element, renderingMode: .alwaysOriginal)
        button.setImage(editIcon, for: UIControl.State())
        button.layer.cornerRadius = Constants.navigationBarButtonsSize / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(changeInfoAccount), for: .touchUpInside)
        button.backgroundColor = Colors.Backgorunds.plate
        return button
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Constants.cityFont
        label.text = "Город"
        label.textColor = Colors.Text.secondary
        return label
    }()
    
    private let subscribeSegmentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let menuSegmentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private let horizontalScrollableStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private let comingSoonView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.8)
        view.layer.cornerRadius = 15
        view.layer.cornerCurve = .continuous
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 28, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        let stringValue = "Дарты\nДонаты\nDarty MAX\nСкоро"
        let attrString = NSMutableAttributedString(string: stringValue)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 24 // change line spacing between paragraph like 36 or 48
        style.minimumLineHeight = 20 // change line spacing between each line like 30 or 40
        style.alignment = .center
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: stringValue.count))
        attrString.addAttribute(NSAttributedString.Key.kern, value: 2, range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(32)
        }
        return view
    }()

    private let buyDartsView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 15
        view.layer.cornerCurve = .continuous

        let iconConfing = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 32, weight: .medium))
        let iconImageView = UIImageView(image: UIImage(systemName: "moon.circle.fill", withConfiguration: iconConfing)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal))
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = Constants.buyDartsTitleText
        titleLabel.font = Constants.subscribeButtonsTitleFont
        titleLabel.textColor = .secondaryLabel
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        
        let textLabel = UILabel()
        textLabel.text = Constants.buyDartsActionText
        textLabel.font = Constants.subscribeButtonsTitleFont
        textLabel.textColor = .systemIndigo
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.bottom.equalToSuperview().inset(12)
        }
        
        return view
    }()
    
    private let donateView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 15
        view.layer.cornerCurve = .continuous

        let iconConfing = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 32, weight: .medium))
        let iconImageView = UIImageView(image: UIImage(systemName: "heart.fill", withConfiguration: iconConfing)?.withTintColor(.systemPink, renderingMode: .alwaysOriginal))
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = Constants.donateTitleText
        titleLabel.font = Constants.subscribeButtonsTitleFont
        titleLabel.textColor = .secondaryLabel
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        
        let textLabel = UILabel()
        textLabel.text = Constants.donateActionText
        textLabel.font = Constants.subscribeButtonsTitleFont
        textLabel.textColor = .systemPink
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.bottom.equalToSuperview().inset(12)
        }
        
        return view
    }()
    
    private let firstLineSubscribeButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 32
        return stackView
    }()
    
    private let subscribeView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 15
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        return imageView
    }()
    
    private let subscribeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.subscribeNameLabelFont
        label.text = Constants.subscribeNameLabelText
        label.textColor = .label
        return label
    }()
    
    private let subscribeInfoLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.subscribeInfoLabelFont
        label.text = Constants.subscribeInfoLabelText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = Constants.subscribeInfoLabelColor
        return label
    }()
    
    private let subscribeExpiredLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.subscribeExpiredLabelFont
        label.text = Constants.subscribeExpiredLabelPlaceholder
        return label
    }()
    
    private let subscribeExpiredView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .secondarySystemGroupedBackground.withAlphaComponent(0.8)
        return view
    }()

    // MARK: - Properties
    private var themeMode: ThemeChangeMode = .auto
    private var isAfterTappedToSegmentedControl = false

    private let settingsList = [
        MenuCellModel(title: "Сменить номер", icon: "􀍄", action: #selector(changePhone)),
        MenuCellModel(title: "Обратная связь", icon: "􀭽", action: #selector(contactWithUsAction)),
        MenuCellModel(title: "Уведомления", icon: "􀋙", action: #selector(notificationsAction)),
        MenuCellModel(title: "Поставить оценку", icon: "􀉿", action: #selector(rateUsAction)),
        MenuCellModel(title: "Поделиться приложением", icon: "􀌤", action: #selector(shareApp)),
        MenuCellModel(title: "Выйти из аккаунта", icon: "􀻵", action: #selector(logoutAction), color: Colors.Statuses.error)
    ]

    // MARK: - Delegate
    weak var delegate: AccountCoordinatorDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setupUserInfo),
            name: GlobalConstants.changedUserDataNotification.name,
            object: nil
        )
        setupHero()
        setupUserInfo()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setIsTabBarHidden(false)
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: GlobalConstants.changedUserDataNotification.name,
            object: nil
        )
    }

    // MARK: - Setup
    @objc private func setupUserInfo() {
        guard let userData = AuthService.shared.currentUser else {
            print("ERROR_LOG Error get user data from AuthService.shared.currentUser")
            return
        }
        
        StorageService.shared.downloadImage(url: URL(string: userData.avatarStringURL)!) { [weak self] result in
            switch result {
            case .success(let image):
                self?.userAvatarImageView.image = image
            case .failure(let error):
                print("ERROR_LOG Error download user image: ", error.localizedDescription)
            }
        }

        cityLabel.text = userData.country + ", " + userData.city
        usernameLabel.text = userData.username
    }
    
    private func setupNavigationBar() {
        title = "Настройки"
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: shareButton)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }
    
    private func setupViews() {
        view.addSubview(userAvatarImageView)
        view.addSubview(usernameLabel)
        view.addSubview(cityLabel)
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        scrollView.addSubview(horizontalScrollableStackView)
        horizontalScrollableStackView.addArrangedSubview(menuSegmentContainer)
        horizontalScrollableStackView.addArrangedSubview(subscribeSegmentContainer)
        menuSegmentContainer.addSubview(settingsTableView)
        subscribeSegmentContainer.addSubview(firstLineSubscribeButtonsStackView)
        firstLineSubscribeButtonsStackView.addArrangedSubview(buyDartsView)
        firstLineSubscribeButtonsStackView.addArrangedSubview(donateView)
        subscribeSegmentContainer.addSubview(subscribeView)
        subscribeView.addSubview(dartyLogo)
        subscribeView.addSubview(subscribeNameLabel)
        subscribeView.addSubview(subscribeInfoLabel)
        subscribeView.addSubview(subscribeExpiredView)
        subscribeExpiredView.addSubview(subscribeExpiredLabel)
        subscribeSegmentContainer.addSubview(comingSoonView)
    }

    private func setupHero() {
        userAvatarImageView.hero.id = GlobalConstants.userImageHeroId
    }
    
    // MARK: - Handlers
    @objc private func logoutAction() {
        let ac = UIAlertController(title: "Выход из аккаунта", message: "Вы уверены что хотите выйти?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (_) in
            do {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.appCoordinator?.openAuthFlow()
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func themeSwitchAction() {
        switch themeMode {
        case .manual:
//            darkModeButton.setImage(autoIcon, for: UIControl.State())
            themeMode = .auto
            overrideUserInterfaceStyle = .dark
        case .auto:
//            darkModeButton.setImage(handIcon, for: UIControl.State())
            themeMode = .manual
            overrideUserInterfaceStyle = .unspecified
        }
    }
    
    @objc private func shareAccount() {
        ShareHelper.share(user: FirestoreService.shared.currentUser, from: self)
    }
    
    @objc private func changeInfoAccount() {
        delegate?.openChangeInfo(preloadedUserImage: userAvatarImageView.image, isNeedAnimatedShowImage: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        isAfterTappedToSegmentedControl = true
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowAnimatedContent]) {
                self.scrollView.setContentOffset(CGPoint(x: self.menuSegmentContainer.frame.minX, y: 0), animated: false)
            } completion: { flag in
                self.isAfterTappedToSegmentedControl = false
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowAnimatedContent]) {
                self.scrollView.setContentOffset(CGPoint(x: self.subscribeSegmentContainer.frame.minX, y: 0), animated: false)
            } completion: { flag in
                self.isAfterTappedToSegmentedControl = false
            }
        }
    }
    
    @objc private func rateUsAction() {
        var components = URLComponents(url: Constants.productUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = [
          URLQueryItem(name: "action", value: "write-review")
        ]
        guard let writeReviewURL = components?.url else {
          return
        }
        UIApplication.shared.open(writeReviewURL)
    }
    
    @objc private func shareApp() {
        let activityViewController = UIActivityViewController(
            activityItems: [Constants.productUrl],
          applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func changePhone() {
        delegate?.openChangePhone()
    }
    
    @objc private func contactWithUsAction() {
        delegate?.openContactsWithUs()
    }

    @objc private func notificationsAction() {
        delegate?.openNotificationsSettings()
    }
    
    @objc private func openAboutUser(_ sender: UITapGestureRecognizer) {
        guard let userData = AuthService.shared.currentUser else {
            print("ERROR_LOG Error get user data from AuthService.shared.currentUser")
            return
        }
        sender.view?.showAnimation {
            self.delegate?.openAbout(userData: userData, preloadedUserImage: self.userAvatarImageView.image)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension AccountVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isAfterTappedToSegmentedControl == false {
            var previousPage : Int = 0
            let pageWidth : CGFloat = scrollView.frame.size.width
            let fractionalPage = Float(scrollView.contentOffset.x / pageWidth)
            let page = lroundf(fractionalPage)
            if previousPage != page {
                previousPage = page
            }
            segmentedControl.selectedSegmentIndex = previousPage
        }
    }
}

// MARK: - Setup constraints
extension AccountVC {
    private func setupConstraints() {
        userAvatarImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.equalToSuperview().offset(24)
            make.size.equalTo(Constants.userAvatarSize)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(userAvatarImageView.snp.top).offset(8)
            make.left.equalToSuperview().offset(48 + Constants.userAvatarSize)
            make.right.equalToSuperview().offset(-24)
        }

        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(12)
            make.left.equalTo(usernameLabel.snp.left)
            make.right.equalToSuperview().offset(-24)
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(userAvatarImageView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(24)
            make.left.right.bottom.equalToSuperview()
        }

        horizontalScrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(scrollView.snp.height)
        }

        horizontalScrollableStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 2).isActive = true

        subscribeSegmentContainer.snp.makeConstraints { make in
            make.width.equalTo(view.frame.size.width)
        }

        firstLineSubscribeButtonsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }

        subscribeView.snp.makeConstraints { make in
            make.top.equalTo(firstLineSubscribeButtonsStackView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        dartyLogo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(Constants.subscribeDartyLogoSize)
        }

        subscribeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(dartyLogo.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        subscribeInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(subscribeNameLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        subscribeExpiredView.snp.makeConstraints { make in
            make.top.equalTo(subscribeInfoLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(18)
        }

        subscribeExpiredLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Constants.subscribeExpiredLabelTopBottomInsets)
            make.left.right.equalToSuperview().inset(Constants.subscribeExpiredLabelLeftRightInsets)
        }

        view.layoutIfNeeded()
        subscribeExpiredView.layer.cornerRadius = subscribeExpiredView.frame.size.height / 2

        menuSegmentContainer.snp.makeConstraints { make in
            make.width.equalTo(view.frame.size.width)
            make.top.bottom.equalToSuperview()
        }

        settingsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        comingSoonView.snp.makeConstraints { make in
            make.top.equalTo(firstLineSubscribeButtonsStackView.snp.top)
            make.left.equalTo(firstLineSubscribeButtonsStackView.snp.left)
            make.right.equalTo(donateView.snp.right)
            make.bottom.equalTo(subscribeView.snp.bottom)
        }
    }
}

extension AccountVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuCell.reuseIdentifier,
            for: indexPath
        ) as? MenuCell else {
            return UITableViewCell()
        }
        let item = settingsList[indexPath.row]
        let context = MenuCell.Context(title: item.title, icon: item.icon, color: item.color)
        cell.configure(with: context)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        let action = settingsList[indexPath.row].action
        perform(action)
    }
}
