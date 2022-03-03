//
//  ChangeAccountDataInfoViewVC.swift
//  Darty
//
//  Created by Руслан Садыков on 08.09.2021.
//

import UIKit
import SPAlert
import Agrume

final class ChangeAccountDataInfoViewVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let textColor: UIColor = .white
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .medium)
        
        static let descriptionTitleText = "Описание"
        static let descriptoonTextFont: UIFont? = .sfProText(ofSize: 12, weight: .regular)
        
        static let interestsTitleText = "Интересы"
        
        static let sectionInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        static let spacingInterest: CGFloat = 12
        
        static let arrowSize: CGFloat = 30
        
        static let birthdayTitleLabelText = "Дата рождения"
        static let sexTitleLabelText = "Пол"
        
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 14, weight: .medium)
        
        static let instagramTitleLabelText = "Мои фото в Instagram"
        
        static let playlistTitleLabelText = "Плейлист"
    }
    
    // MARK: - UI Elements
    let arrowDirectionImageView: ArrowView = {
        let arrow = ArrowView(frame: CGRect(x: 0, y: 0, width: Constants.arrowSize, height: Constants.arrowSize))
        arrow.arrowAnimationDuration = 0.3
        arrow.arrowColor = Constants.textColor
        arrow.update(to: .middle, animated: false)
        return arrow
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var nameTextField: TextField = {
        let textField = TextField(color: .systemIndigo, placeholder: "Имя")
        textField.delegate = self
        return textField
    }()
    
    private lazy var aboutTextView: TextView = {
        let textView = TextView(placeholder: "Обо мне", isEditable: true, color: .systemIndigo)
        textView.delegate = self
        return textView
    }()
    
    private let birthdayTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        label.text = Constants.birthdayTitleLabelText
        return label
    }()
    
    private let birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .systemIndigo
        datePicker.addTarget(self, action: #selector(changedBirthday), for: .valueChanged)
        return datePicker
    }()
    
    private let sexTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.sexTitleLabelText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private let sexSegmentControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["М", "Ж", "Другое", "Не указан"])
        segmentedControl.selectedSegmentIndex = 3
        let attr = NSDictionary(object: Constants.segmentFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.addTarget(self, action: #selector(sexChangedAction(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private let interestsTitleLable: UILabel = {
        let label = UILabel()
        label.text = Constants.interestsTitleText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private lazy var interestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.register(InterestCell.self, forCellWithReuseIdentifier: InterestCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        return collectionView
    }()
    
    private let changeInterestsButton: UIButton = {
        let button = UIButton(title: "Выбрать интересы")
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(changeInterestsOpen), for: .touchUpInside)
        return button
    }()
    
    private let instagramTitleLable: UILabel = {
        let label = UILabel()
        label.text = Constants.instagramTitleLabelText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private let connectInstagramButton: UIButton = {
        let button = UIButton(title: "Подключить Instagram")
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(connectInstagram), for: .touchUpInside)
        return button
    }()
    
    private lazy var instagramPhotosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.register(InstagramPhotoCell.self, forCellWithReuseIdentifier: InstagramPhotoCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        return collectionView
    }()
    
    private let playlistTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.playlistTitleLabelText
        label.font = Constants.titleFont
        label.textColor = Constants.textColor
        return label
    }()
    
    private lazy var playlistCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.register(InstagramPhotoCell.self, forCellWithReuseIdentifier: InstagramPhotoCell.reuseIdentifier)
        //        collectionView.delegate = self
        //        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let connectAppleMusicButton: UIButton = {
        let button = UIButton(title: "Подключить Apple Music")
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(connectAppleMusic), for: .touchUpInside)
        return button
    }()
    
    private let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    // MARK: - Properties
    private var instagramApi = InstagramApi.shared
    private var instagramUser: InstagramUser?
    private var instagramPhotos: [InstaMediaData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.instagramPhotosCollectionView.reloadSections([0])
            }
        }
    }
    private var instagramPhotoUrls: [URL] = []
    
    private var userData: UserModel
    private var accentColor: UIColor
    
    // MARK: - Init
    init(userData: UserModel, accentColor: UIColor) {
        self.userData = userData
        self.accentColor = accentColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadInterests), name: GlobalConstants.changedUserInterestsNotification.name, object: nil)
        addHideKeyboardOnTapAround()
        setupUser()
        setupViews()
        setupConstraints()
    }
    
    private func addHideKeyboardOnTapAround() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    private func setupUser() {
        nameTextField.text = userData.username
        aboutTextView.text = userData.description
        
        birthdayDatePicker.date = userData.birthday
        
        switch userData.sex {
        case "man":
            sexSegmentControl.selectedSegmentIndex = 0
        case "woman":
            sexSegmentControl.selectedSegmentIndex = 1
        case "another":
            sexSegmentControl.selectedSegmentIndex = 2
        default:
            break
        }
        
        if UserDefaults.standard.instagramAccessToken != nil {
            connectInstagramButton.isHidden = true
            getInstaPhotos()
        }
    }
    
    private func setupViews() {
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.contentView.addSubview(arrowDirectionImageView)
        blurEffectView.contentView.addSubview(scrollView)
        
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(aboutTextView)
        scrollView.addSubview(birthdayTitleLabel)
        scrollView.addSubview(birthdayDatePicker)
        scrollView.addSubview(sexTitleLabel)
        scrollView.addSubview(sexSegmentControl)
        scrollView.addSubview(interestsTitleLable)
        scrollView.addSubview(interestsCollectionView)
        scrollView.addSubview(changeInterestsButton)
        scrollView.addSubview(instagramTitleLable)
        scrollView.addSubview(instagramPhotosCollectionView)
        scrollView.addSubview(connectInstagramButton)
        scrollView.addSubview(playlistTitleLabel)
        scrollView.addSubview(playlistCollectionView)
        scrollView.addSubview(connectAppleMusicButton)
    }
    
    private func setupConstraints() {
        arrowDirectionImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(Constants.arrowSize)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.left.right.equalToSuperview().inset(20)
        }
        
        aboutTextView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(128)
        }
        
        birthdayTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(aboutTextView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        birthdayDatePicker.snp.makeConstraints { make in
            make.top.equalTo(birthdayTitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
        }
        
        sexTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(birthdayDatePicker.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        sexSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(sexTitleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        interestsTitleLable.snp.makeConstraints { make in
            make.top.equalTo(sexSegmentControl.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        // Этот элемент растягивает scroll view по ширине
        interestsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(interestsTitleLable.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(54)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.size.width)
        }
        
        changeInterestsButton.snp.makeConstraints { make in
            make.top.equalTo(interestsCollectionView.snp.bottom).offset(16)
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(20)
        }
        
        instagramTitleLable.snp.makeConstraints { make in
            make.top.equalTo(changeInterestsButton.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        instagramPhotosCollectionView.snp.makeConstraints { make in
            make.top.equalTo(instagramTitleLable.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        connectInstagramButton.snp.makeConstraints { make in
            make.top.equalTo(instagramTitleLable.snp.bottom).offset(16)
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(20)
        }
        
        playlistTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(instagramPhotosCollectionView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(26)
        }
        
        playlistCollectionView.backgroundColor = .green
        playlistCollectionView.snp.makeConstraints { make in
            make.top.equalTo(playlistTitleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        connectAppleMusicButton.snp.makeConstraints { make in
            make.top.equalTo(playlistTitleLabel.snp.bottom).offset(16)
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-96)
        }
    }
    
    // MARK: - Handlers
    @objc private func tapAction() {
        self.view.endEditing(true)
    }
    
    @objc private func reloadInterests() {
        DispatchQueue.main.async() {
            self.interestsCollectionView.reloadSections([0])
        }
        updateUserDataInFirestore()
    }
    
    @objc private func sexChangedAction(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            AuthService.shared.currentUser.sex = Sex.man.rawValue
        case 1:
            AuthService.shared.currentUser.sex = Sex.woman.rawValue
        case 2:
            AuthService.shared.currentUser.sex = Sex.another.rawValue
        case 3:
            AuthService.shared.currentUser.sex = nil
        default:
            break
        }
        
        updateUserDataInFirestore()
    }
    
    @objc private func changeInterestsOpen() {
        let changeAccountInterests = ChangeAccountInteretsVC()
        navigationController?.pushViewController(changeAccountInterests, animated: true)
    }
    
    @objc private func changedBirthday() {
        AuthService.shared.currentUser.birthday = birthdayDatePicker.date
        updateUserDataInFirestore()
    }
    
    private func updateUserDataInFirestore() {
        DispatchQueue.main.async {
            self.startLoading()
        }
        FirestoreService.shared.updateUserInformation(userData: AuthService.shared.currentUser) { [weak self] result in
            switch result {
            
            case .success():
                DispatchQueue.main.async {
                    self?.stopLoading()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.stopLoading()
                    SPAlert.present(title: error.localizedDescription, preset: .error)
                }
            }
        }
    }
    
    @objc private func connectInstagram() {
        let instaAuthVC = InstaAuthViewController(instagramApi: instagramApi)
        instaAuthVC.delegate = self
        present(instaAuthVC, animated:true)
    }
    
    private func getInstaPhotos() {
        if let accessToken = UserDefaults.standard.instagramAccessToken {
            self.instagramApi.getMediaData(accessToken: accessToken, completion: { [weak self] instagramMediaData in
                print("asdioajidaiosjdiasjoidjaisjoidas")
                if let error = instagramMediaData.error {
                    DispatchQueue.main.async {
                        self?.connectInstagramButton.isHidden = false
                        SPAlert.present(title: "Instagram: " + error.errorUserTitle, message: error.errorUserMsg, preset: .error)
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.connectInstagramButton.isHidden = true
                }
                if let instaPhotos = instagramMediaData.data?.sorted(by: { $0.timestamp > $1.timestamp }).filter({ instaMediaDataItem in
                    instaMediaDataItem.mediaType == .IMAGE
                }) {
                    self?.instagramPhotoUrls = instaPhotos.map({ instaMediaDataItem in
                        instaMediaDataItem.mediaUrl
                    })
                    self?.instagramPhotos = instaPhotos
                }
            })
        }
    }
    
    @objc private func connectAppleMusic() {
        
    }
    
    @objc private func showFullImageAction(_ sender: UITapGestureRecognizer) {
        sender.view?.showAnimation { [weak self] in
            guard let self = self else { return }
            
            let button = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
            
            let agrume = Agrume(urls: self.instagramPhotoUrls,
                                startIndex: sender.view?.tag ?? 0,
                                background: .blurred(.light),
                                dismissal: .withPhysicsAndButton(button))

            agrume.didScroll = { [unowned self] index in
                self.instagramPhotosCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: false)
            }
            
            let helper = AgrumeHelper.shared.makeHelper()
            agrume.onLongPress = helper.makeSaveToLibraryLongPressGesture
            
            agrume.show(from: self)
        }
    }
}

// MARK: - InstaAuthDelegate
extension ChangeAccountDataInfoViewVC: InstaAuthDelegate {
    func didGetUserData(_ instaUser: InstagramTestUser) {
        startLoading()
        instagramApi.getLongTermAccessTiken(accessToken: instaUser.accessToken) { [weak self] instaLongTermAccessToken in
            guard let self = self else { return }
            if let error = instaLongTermAccessToken.error {
                DispatchQueue.main.async {
                    self.stopLoading()
                    SPAlert.present(title: "Instagram: " + error.errorUserTitle, message: error.errorUserMsg, preset: .error)
                }
                return
            }
            self.instagramApi.getInstagramUser(testUserData: instaUser) { [weak self] (user) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.stopLoading()
                    SPAlert.present(title: "Вход выполнен с акканта:", message: user.username, preset: .done)
                }
                AuthService.shared.currentUser.instagramId = user.id
                self.updateUserDataInFirestore()
                self.instagramUser = user
                UserDefaults.standard.instagramAccessToken = instaLongTermAccessToken.accessToken
                self.getInstaPhotos()
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension ChangeAccountDataInfoViewVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        AuthService.shared.currentUser.username = textField.text ?? userData.username
        updateUserDataInFirestore()
    }
}

// MARK: - TextViewDelegate
extension ChangeAccountDataInfoViewVC: TextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        AuthService.shared.currentUser.description = textView.text ?? userData.description
        updateUserDataInFirestore()
    }
}

// MARK: UICollectionViewDataSource
extension ChangeAccountDataInfoViewVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == interestsCollectionView {
            return AuthService.shared.currentUser.interestsList.count
        } else if collectionView == instagramPhotosCollectionView {
            return instagramPhotoUrls.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == interestsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestCell.reuseIdentifier, for: indexPath) as! InterestCell
            let interest = GlobalConstants.interestsArray[AuthService.shared.currentUser.interestsList[indexPath.row]]
            
            cell.setupCell(title: interest.title, emoji: interest.emoji)
            cell.isSelected = true
            
            return cell
        } else if collectionView == instagramPhotosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InstagramPhotoCell.reuseIdentifier, for: indexPath) as! InstagramPhotoCell
            let photoUrl = instagramPhotoUrls[indexPath.row]
            cell.configure(with: photoUrl)
            cell.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullImageAction(_:)))
            cell.addGestureRecognizer(tapGestureRecognizer)
            return cell
        } else {
            
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChangeAccountDataInfoViewVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.spacingInterest
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.spacingInterest
    }
}
