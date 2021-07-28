//
//  AboutPartyVC.swift
//  Darty
//
//  Created by Руслан Садыков on 21.07.2021.
//

import UIKit
import Lightbox
import SPAlert
import FittedSheets

enum AboutPartyVCType {
    case search
    case approved
    case waiting
    case my
    case archive
}

final class AboutPartyVC: UIViewController {
    
    private enum Constants {
        static let titleElementsFont: UIFont? = .sfProRounded(ofSize: 12, weight: .semibold)
        static let titleLabelsFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
        static let contentLabelsFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
        
        static let locationTitleText = "Местоположение"
        static let themeTitleText = "Тематика"
        
        static let sectionInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        static let ownerImageSize: CGFloat = 44
        static let ownerNameFont: UIFont? = .sfProDisplay(ofSize: 12, weight: .semibold)
        static let ownerRatingFont: UIFont? = .sfProRounded(ofSize: 12, weight: .semibold)
        static let partyDescriptionFint: UIFont? = .sfProRounded(ofSize: 10, weight: .regular)
    }
    
    // MARK: - UI Elements
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleElementsFont
        return label
    }()
    
    private let minAgeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleElementsFont
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleElementsFont
        return label
    }()
    
    private let themeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleLabelsFont
        label.text = Constants.themeTitleText
        return label
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.contentLabelsFont
        return label
    }()
    
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleLabelsFont
        label.text = Constants.locationTitleText
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.contentLabelsFont
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Показать на карте", for: .normal)
        let mapIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 14, weight: .semibold))
        let mapIcon = UIImage(systemName: "map", withConfiguration: mapIconConfig)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        button.setImage(mapIcon, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8941176471, alpha: 1)
        button.layer.cornerRadius = 16
        button.tintColor = .systemOrange
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        return button
    }()
    
    private let imagesTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.contentLabelsFont
        label.text = "Изображения"
        return label
    }()
    
    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 118, height: 96), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(PartyImageCell.self, forCellWithReuseIdentifier: PartyImageCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let guestsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.contentLabelsFont
        label.text = "Приглашенные гости"
        return label
    }()
    
    private lazy var guestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let ownerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.ownerImageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray
        return imageView
    }()
    
    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ownerNameFont
        return label
    }()
    
    private let ownerRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ownerRatingFont
        label.textAlignment = .left
        return label
    }()
    
    private let partyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Constants.partyDescriptionFint
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(title: "Отправить заявку 􀝻")
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(actionButtonAction), for: .touchDown)
        return button
    }()
    
    private lazy var cancelPartyButton: UIButton = {
        let button = UIButton(title: "Отменить вечеринку 􀆄")
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(cancelPartyAction), for: .touchDown)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Properties
    private var waitingUsers: [UserModel] = []
    private var approvedUsers: [UserModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.guestsCollectionView.reloadData()
            }
        }
    }
    private let party: PartyModel
    private let type: AboutPartyVCType
    private var ownerData: UserModel?
    
    // MARK: - Lifecycle
    init(party: PartyModel, type: AboutPartyVCType) {
        self.party = party
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        expandTabBar(false)
     
        getGuests()
        
        setupParty()
        setupViews()
        setupConstraints()
        
        if type == .search {
            checkWaitingGuest()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(false)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func getGuests() {
        FirestoreService.shared.getApprovedGuestsId(party: self.party) { [weak self] result in
            
            switch result {
            
            case .success(let usersId):
                
                for userId in usersId {
                    
                    FirestoreService.shared.getUser(by: userId) { result in
                        
                        switch result {
                        
                        case .success(let user):
                            self?.approvedUsers.append(user)
                        case .failure(let error):
                            self?.showAlert(title: "Ошибка!", message: error.localizedDescription)
                        }
                    }
                }
                    
            case .failure(let error):
                if error as? PartyError == PartyError.noApprovedGuests {
                    print(error.localizedDescription)
                } else {
                    self?.showAlert(title: "Ошибка!", message: error.localizedDescription)
                    print(error.localizedDescription)
                }
            }
        }
        
        let dg = DispatchGroup()
        dg.enter()
        FirestoreService.shared.getWaitingGuestsId(party: self.party) { [weak self] result in
            
            switch result {
            
            case .success(let usersId):
                
                for userId in usersId {
                    
                    FirestoreService.shared.getUser(by: userId) { result in
                        
                        switch result {
                        
                        case .success(let user):
                            self?.waitingUsers.append(user)
                        case .failure(let error):
                            self?.showAlert(title: "Ошибка!", message: error.localizedDescription)
                        }
                        dg.leave()
                    }
                }
                    
            case .failure(let error):
                if error as? PartyError == PartyError.noWaitingGuests {
                    print(error.localizedDescription)
                } else {
                    self?.showAlert(title: "Ошибка!", message: error.localizedDescription)
                    print(error.localizedDescription)
                }
                dg.leave()
            }
        }

    dg.notify(queue: .main) { [weak self] in
        if self?.type == .my {
            if let count = self?.waitingUsers.count {
                if count > 0 {
                    self?.actionButton.setTitle("Новые заявки \(count) 􀋙", for: .normal)
                    self?.actionButton.isEnabled = true
                }
            }
        }
    }
    }
    
    private func setupParty() {
        dateLabel.text = DateFormatter.ddMMMM.string(from: party.date)
        minAgeLabel.text = "\(party.minAge)+"
        timeLabel.text = DateFormatter.HHmm.string(from: party.startTime)
        if let endTime = party.endTime {
            timeLabel.text?.append(" 􀄫 \(DateFormatter.HHmm.string(from: endTime))")
        }
        locationLabel.text = party.location
        themeLabel.text = party.type
        imagesTitleLabel.text = "Изображения " + String(party.imageUrlStrings.count)
        partyDescriptionLabel.text = party.description
        
        getOwnerData()
    }
    
    private func getOwnerData() {
        FirestoreService.shared.getUser(by: party.userId) { [weak self] result in
            switch result {
            
            case .success(let user):
                if let imageUrl = URL(string: user.avatarStringURL) {
                    self?.ownerImageView.sd_setImage(with: imageUrl, completed: { image, error, cacheType, url in
                        self?.ownerImageView.focusOnFaces = true
                    })
                }
                self?.ownerNameLabel.text = user.username
                self?.ownerRatingLabel.text = "0.0 *"
                self?.ownerData = user
                self?.addTapToOwner()
            case .failure(let error):
                print("ERROR_LOG Failure get user data from party: ", error.localizedDescription)
            }
        }
    }
    
    private func addTapToOwner() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAboutOwner))
        tapGestureRecognizer.numberOfTapsRequired = 1
        ownerImageView.addGestureRecognizer(tapGestureRecognizer)
        ownerImageView.isUserInteractionEnabled = true
    }
    
    private func setupNavigationBar() {
        setNavigationBar(withColor: .systemOrange, title: party.name, withClear: false)
        let shareIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up", withConfiguration: shareIconConfig)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(shareAction))
        navigationItem.rightBarButtonItem = shareBarButtonItem
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(minAgeLabel)
        scrollView.addSubview(timeLabel)
        scrollView.addSubview(themeTitleLabel)
        scrollView.addSubview(themeLabel)
        scrollView.addSubview(locationTitleLabel)
        scrollView.addSubview(locationLabel)
        scrollView.addSubview(locationButton)
        scrollView.addSubview(imagesTitleLabel)
        scrollView.addSubview(imagesCollectionView)
        scrollView.addSubview(guestsTitleLabel)
        scrollView.addSubview(guestsCollectionView)
        scrollView.addSubview(ownerImageView)
        scrollView.addSubview(ownerNameLabel)
        scrollView.addSubview(ownerRatingLabel)
        scrollView.addSubview(partyDescriptionLabel)
        view.addSubview(actionButton)
        view.addSubview(cancelPartyButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.safeAreaInsets.top + 16)
            make.left.equalToSuperview().offset(32)
        }
        
        minAgeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(dateLabel.snp.centerY)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.centerY.equalTo(minAgeLabel.snp.centerY)
        }
        
        themeTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.top).offset(32)
        }
        
        themeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(themeTitleLabel.snp.bottom).offset(12)
        }
        
        locationTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(themeLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(locationTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        
        locationButton.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
        
        imagesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(locationButton.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(20)
        }
        
        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(imagesTitleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(96)
        }
        
        guestsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(20)
        }
        
        guestsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(guestsTitleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.width.equalTo(view.frame.size.width) // С помощью этого мы делаем scroll view на всю ширину
        }
        
        ownerImageView.snp.makeConstraints { make in
            make.top.equalTo(guestsCollectionView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(26)
            make.size.equalTo(Constants.ownerImageSize)
        }
        
        ownerNameLabel.snp.makeConstraints { make in
            make.top.equalTo(ownerImageView.snp.top)
            make.left.equalTo(ownerImageView.snp.right).offset(10)
            make.right.equalTo(ownerRatingLabel.snp.left).offset(-4)
        }
        
        ownerRatingLabel.snp.makeConstraints { make in
            make.left.equalTo(ownerNameLabel.snp.right).offset(4).priority(.high)
            make.centerY.equalTo(ownerNameLabel.snp.centerY)
            make.right.equalToSuperview().inset(10).priority(.low)
        }
        
        partyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(ownerNameLabel.snp.bottom).offset(6)
            make.left.equalTo(ownerNameLabel.snp.left)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-Constants.ownerImageSize - 128)
        }
        
        switch type {
        case .search:
            actionButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32 + GlobalConstants.tabBarHeight)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
        case .approved:
            actionButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32 + GlobalConstants.tabBarHeight)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
            changeToApprovedButton()
        case .waiting:
            cancelPartyButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32 + GlobalConstants.tabBarHeight)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
            cancelPartyButton.isHidden = false
            cancelPartyButton.setTitle("Отменить заявку 􀆄", for: .normal)
            
            actionButton.snp.makeConstraints { make in
                make.bottom.equalTo(cancelPartyButton.snp.top).offset(-16)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
            changeToSendButton()
        case .my:
            cancelPartyButton.isHidden = false
            cancelPartyButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(54)
                make.left.equalToSuperview().inset(20)
                make.right.equalToSuperview().inset(112)
                make.height.equalTo(50)
            }
            
            actionButton.snp.makeConstraints { make in
                make.bottom.equalTo(cancelPartyButton.snp.top).offset(-16)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
            
            let count = waitingUsers.count
            if count > 0 {
                actionButton.setTitle("Новые заявки \(count) 􀋙", for: .normal)
            } else {
                actionButton.setTitle("Новых заявок нет", for: .normal)
                actionButton.backgroundColor = .systemYellow
                actionButton.isEnabled = false
            }
           
        case .archive:
            break
        }
    }
    
    // MARK: - Handlers
    @objc private func showAboutOwner() {
        print("asdijasoidajsdioaj")
        guard let ownerData = ownerData else { return }
        let aboutUserVC = AboutUserVC(userData: ownerData, type: .info)
        navigationController?.pushViewController(aboutUserVC, animated: true)
    }
    
    private func changeToSendButton() {
        actionButton.setTitle("Заявка отправлена 􀕺", for: .normal)
        actionButton.backgroundColor = .systemYellow
        actionButton.isEnabled = false
    }
    
    private func changeToApprovedButton() {
        actionButton.setTitle("Вы приглашены 􀯧", for: .normal)
        actionButton.backgroundColor = .systemGreen
        actionButton.isEnabled = false
    }
    
    @objc private func shareAction() {
        
    }
    
    func showMessageVC() {
        let options = SheetOptions(
            // The full height of the pull bar. The presented view controller will treat this area as a safearea inset on the top
            pullBarHeight: 0,
            
            // The corner radius of the shrunken presenting view controller
            presentingViewCornerRadius: 30,
            
            // Extends the background behind the pull bar or not
            shouldExtendBackground: false,
            
            // Attempts to use intrinsic heights on navigation controllers. This does not work well in combination with keyboards without your code handling it.
            setIntrinsicHeightOnNavigationControllers: false,
            
            // Pulls the view controller behind the safe area top, especially useful when embedding navigation controllers
            useFullScreenMode: false,
            
            // Shrinks the presenting view controller, similar to the native modal
            shrinkPresentingViewController: false,
            
            // Determines if using inline mode or not
            useInlineMode: false,
            
            // Adds a padding on the left and right of the sheet with this amount. Defaults to zero (no padding)
            horizontalPadding: 0,
            
            // Sets the maximum width allowed for the sheet. This defaults to nil and doesn't limit the width.
            maxWidth: nil
        )
        
        let messageForRequestVC = MessageForRequestVC(delegate: self)
        let sheetController = SheetViewController(controller: messageForRequestVC, sizes: [], options: options)
        sheetController.allowPullingPastMaxHeight = false
        sheetController.contentBackgroundColor = .clear
        present(sheetController, animated: true, completion: nil)
    }
    
    @objc private func actionButtonAction() {
        switch type {
        case .search:
            showMessageVC()
        case .approved, .waiting, .archive:
            break
        case .my:
            let waitingGuestsVC = WaitingGuestsVC(users: waitingUsers, party: party)
            navigationController?.pushViewController(waitingGuestsVC, animated: true)
        }
    }
    
    private func checkWaitingGuest() {
        FirestoreService.shared.checkWaitingGuest(receiver: party.id) { [weak self] (result) in
            switch result {
            case .success():
                self?.changeToSendButton()
                if self?.type != .search {
                    SPAlert.present(title: "Заявка отправлена", preset: .done)
                }
            case .failure(let error):
                SPAlert.present(title: "Не удалось отправить заявку: \(error.localizedDescription)", preset: .error)
            }
        }
    }
    
    @objc private func cancelPartyAction() {
        let alertController = UIAlertController(title: "Вы уверены?", message: "Ваша вечеринка с записанными гостями будет безвозвратно удалена", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Да, отменить", style: .destructive) { (_) in
            #warning("Нужно добавить функционал отмены вечеринки")
        }
        let dismissAction = UIAlertAction(title: "Нет, оставить", style: .cancel) { _ in
            
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func showFullImageAction(_ sender: UITapGestureRecognizer) {
        LightboxConfig.CloseButton.text = ""
        LightboxConfig.CloseButton.image = UIImage(systemName: "xmark.circle")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        LightboxConfig.DeleteButton.image = UIImage(systemName: "trash.circle")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        LightboxConfig.DeleteButton.text = ""
        LightboxConfig.PageIndicator.separatorColor = .clear
        let attributes = [NSAttributedString.Key.font: UIFont.sfProDisplay(ofSize: 18, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemBackground]
        LightboxConfig.PageIndicator.textAttributes = attributes as [NSAttributedString.Key : Any]
        sender.view?.showAnimation { [weak self] in
            // Create an array of images.
            var images: [LightboxImage] = []
            self?.party.imageUrlStrings.forEach { imageUrlString in
                guard let imageUrl = URL(string: imageUrlString) else { return }
                images.append(LightboxImage(imageURL: imageUrl))
            }
            
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            
            // Set delegates.
            controller.dismissalDelegate = self
            
            // Use dynamic background.
            controller.dynamicBackground = true
            
            controller.goTo(sender.view?.tag ?? 0)
            
            controller.view.backgroundColor = .systemBackground
            
            // Present your controller.
            self?.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: UICollectionViewDataSource
extension AboutPartyVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if collectionView == guestsCollectionView {
            return approvedUsers.count
        } else {
            return party.imageUrlStrings.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == guestsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
            
            cell.configure(with: approvedUsers[indexPath.row])
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PartyImageCell.reuseIdentifier, for: indexPath) as! PartyImageCell
            
            if let imageURL = URL(string: party.imageUrlStrings[indexPath.row]) {
                cell.configure(with: imageURL)
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullImageAction(_:)))
            cell.addGestureRecognizer(tapGestureRecognizer)
            
            return cell
        }
    }
}

extension AboutPartyVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.sectionInsets.left
    }
}

// MARK: - UICollectionViewDelegate
extension AboutPartyVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == guestsCollectionView {
            let user = approvedUsers[indexPath.item]
            
            //        let aboutUserVC = AboutUserViewContoller(user: user)
            //        present(aboutUserVC, animated: true, completion: nil)
        }
        
    }
}

extension AboutPartyVC: LightboxControllerDismissalDelegate {
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        imagesCollectionView.scrollToItem(at: [0,controller.currentPage], at: .centeredHorizontally, animated: false)
    }
}

extension AboutPartyVC: MessageForRequestsDelegate {
    func messageDidEnter(_ message: String) {
        FirestoreService.shared.createWaitingGuest(receiver: party.id, message: message) { [weak self] (result) in
            switch result {
            case .success():
                SPAlert.present(title: "Заявка отправлена", preset: .done)
                self?.checkWaitingGuest()
            case .failure(let error):
                SPAlert.present(title: "Ошибка отправки заявки: \(error.localizedDescription)", preset: .error)
                self?.showAlert(title: "Ошибка!", message: error.localizedDescription)
            }
        }
    }
}