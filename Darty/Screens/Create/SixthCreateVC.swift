//
//  SixthCreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import UIKit
import FirebaseAuth
import YandexMapsMobile

final class SixthCreateVC: UIViewController {
    
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
        static let countFont: UIFont? = .sfProDisplay(ofSize: 22, weight: .semibold)
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
        static let countGuestsText = "Кол-во гостей"
        static let minAgeText = "Мин. возраст"
        static let priceText = "Цена за вход"
    }
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let currentUser: UserModel
    private var setuppedParty: SetuppedParty
    
    // MARK: - Lifecycle
    init(currentUser: UserModel, setuppedParty: SetuppedParty) {
        self.currentUser = currentUser
        self.setuppedParty = setuppedParty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    var collection: YMKClusterizedPlacemarkCollection?
    private func setupMap() {
        let mapView = YMKMapView()
        mapView.mapWindow.map.move(
             with: YMKCameraPosition.init(target: YMKPoint(latitude: 55.751574, longitude: 37.573856), zoom: 15, azimuth: 0, tilt: 0),
             animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
             cameraCallback: nil)
        view = mapView
        mapView.mapWindow.map.move(with:
            YMKCameraPosition(target: YMKPoint(latitude: 0, longitude: 0), zoom: 14, azimuth: 0, tilt: 0))
        
        let scale = UIScreen.main.scale
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        userLocationLayer.setAnchorWithAnchorNormal(
            CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.5 * mapView.frame.size.height * scale),
            anchorCourse: CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.83 * mapView.frame.size.height * scale))
        userLocationLayer.setObjectListenerWith(self)
        
        collection?.addTapListener(with: self)
    }
    
    private func setupNavBar() {
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        let cancelIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let cancelIconImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: cancelIconConfig)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelIconImage, style: .plain, target: self, action: #selector(cancleAction))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        setuppedParty.city = "Санкт Петербург"
        setuppedParty.location = "current"
        
        FirestoreService.shared.savePartyWith(party: setuppedParty) { [weak self] (result) in
            switch result {
            
            case .success(_):
                let alertController = UIAlertController(title: "🎉 Ура! Вечеринка создана. Вы можете найти ее в Мои вечеринки", message: "", preferredStyle: .actionSheet)
                let shareAction = UIAlertAction(title: "Поделиться ссылкой", style: .default) { _ in
                    let items: [Any] = ["This app is my favorite", URL(string: "https://www.apple.com")!]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
                    self?.present(ac, animated: true)
                }
                let goAction = UIAlertAction(title: "Перейти к вечеринке", style: .default) { _ in
                    #warning("Нужно добавить открытие вечеринки и переход в Мои вечеринки")
                }
                
                let doneAction = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                
                alertController.addAction(shareAction)
                alertController.addAction(goAction)
                alertController.addAction(doneAction)
                
                self?.present(alertController, animated: true, completion: nil)
            
            case .failure(let error):
            self?.showAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }
}
    
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Setup constraints
extension SixthCreateVC {
    private func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
    }
}

extension SixthCreateVC: YMKUserLocationObjectListener {
    
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"UserArrow")!)
        
        let pinPlacemark = view.pin.useCompositeIcon()
        
        pinPlacemark.setIconWithName("icon",
            image: UIImage(named:"Icon")!,
            style:YMKIconStyle(
                anchor: CGPoint(x: 0, y: 0) as NSValue,
                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 0,
                flat: true,
                visible: true,
                scale: 1.5,
                tappableArea: nil))
        
        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named:"SearchResult")!,
            style:YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 1,
                tappableArea: nil))

        view.accuracyCircle.fillColor = UIColor.blue
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}

extension SixthCreateVC: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let userPoint = mapObject as? YMKPlacemarkMapObject else {
            return true
        }

        print(userPoint.userData)
        return false
    }
}
