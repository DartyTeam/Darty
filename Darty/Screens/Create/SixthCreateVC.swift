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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private enum Constants {
        static let addressFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
    }
    
    // MARK: - UI Elements
    private let addressTextField: TextField = {
        let textField = TextField(color: .systemPurple, placeholder: "Адрес")
        
        return textField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let userLocationButton: UIButton = {
        let button = UIButton(type: .system)
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        button.setImage(UIImage(systemName: "location.circle.fill", withConfiguration: boldConfig)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.addressFont
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Suggests
    let BOUNDING_BOX = YMKBoundingBox(
        southWest: YMKPoint(latitude: 55.55, longitude: 37.42),
        northEast: YMKPoint(latitude: 55.95, longitude: 37.82))
    let SUGGEST_OPTIONS = YMKSuggestOptions()
    let searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    var suggestSession: YMKSearchSuggestSession!
    var suggestResults: [YMKSuggestItem] = []
    
    private var lastQuery = ""
    private var duplicateQueryCount = 0
    
//    private lazy var suggestsTableView: UITableView = {
//        let tableView = UITableView()
//        tableView.dataSource = self
//        tableView.delegate = self
//        return tableView
//    }()
    
    // MARK: - MapView
    let mapView = YMKMapView()

    // MARK: - Placemark collection
    var collection: YMKClusterizedPlacemarkCollection?
    
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
        setupSearchBar()
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        
        let highlightColor = UIColor.systemPurple.withAlphaComponent(0.3)
        
        searchController.searchBar.searchTextField.markedTextStyle =
            [NSAttributedString.Key.backgroundColor: highlightColor]
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .words
        
        searchController.searchBar.delegate = self
    }
    
 
    private func setupMap() {
        suggestsSetup()
       
        
        mapView.mapWindow.map.move(
             with: YMKCameraPosition.init(target: YMKPoint(latitude: 55.751574, longitude: 37.573856), zoom: 15, azimuth: 0, tilt: 0),
             animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
             cameraCallback: nil)
        view = mapView
        
        let scale = UIScreen.main.scale
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = false
        userLocationLayer.setAnchorWithAnchorNormal(
            CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.5 * mapView.frame.size.height * scale),
            anchorCourse: CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.83 * mapView.frame.size.height * scale))
        userLocationLayer.setObjectListenerWith(self)
//        userLocationLayer.isAutoZoomEnabled = true
//        userLocationLayer.cameraPosition()
        
        
        collection?.addTapListener(with: self)
        
        mapView.mapWindow.map.addTapListener(with: self)
        
        mapView.mapWindow.map.addInputListener(with: self)
        
//        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment.init(horizontalAlignment: .left, verticalAlignment: .bottom))
    }
    
    private func suggestsSetup() {
        suggestSession = searchManager.createSuggestSession()
    }
    
    func onSuggestResponse(_ items: [YMKSuggestItem]) {
        suggestResults = items
    }
    
    func onSuggestError(_ error: Error) {
        let suggestError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if suggestError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if suggestError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
        view.addSubview(addressTextField)
        view.addSubview(nextButton)
        view.addSubview(userLocationButton)
        view.addSubview(addressLabel)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        setuppedParty.city = "Санкт Петербург"
//        setuppedParty.location = "current"
        
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
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.right.equalToSuperview().inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
        
        userLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.bottom.equalTo(addressTextField.snp.top).offset(-24)
        }
    }
}

extension SixthCreateVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let suggestHandler = {(response: [YMKSuggestItem]?, error: Error?) -> Void in
            if let items = response {
                self.onSuggestResponse(items)
            } else {
                self.onSuggestError(error!)
            }
        }
     }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let textField = searchBar.searchTextField
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.tintColor = nil
    }
}

extension SixthCreateVC: YMKUserLocationObjectListener {
    
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(systemName: "location.fill")!)
        
//        let pinPlacemark = view.pin.useCompositeIcon()
        
//        pinPlacemark.setIconWithName("icon",
//            image: UIImage(systemName: "location.north.fill")!,
//            style:YMKIconStyle(
//                anchor: CGPoint(x: 0, y: 0) as NSValue,
//                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
//                zIndex: 0,
//                flat: true,
//                visible: true,
//                scale: 1.5,
//                tappableArea: nil))
        
//        pinPlacemark.setIconWithName(
//            "pin",
//            image: UIImage(systemName:"location.north.fill")!,
//            style:YMKIconStyle(
//                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
//                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
//                zIndex: 1,
//                flat: true,
//                visible: true,
//                scale: 1,
//                tappableArea: nil))

        view.accuracyCircle.fillColor = .systemPurple.withAlphaComponent(0.5)
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}

extension SixthCreateVC: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        print("asdpaskdioasjdaisodjas")
        guard let userPoint = mapObject as? YMKPlacemarkMapObject else {
            return true
        }
        print(userPoint.userData)
        return false
    }
}

extension SixthCreateVC: YMKLayersGeoObjectTapListener {
    func onObjectTap(with event: YMKGeoObjectTapEvent) -> Bool {
        print("asdjasodiasdiasdjasd: ", event.geoObject.geometry)
        return true
    }
}

extension SixthCreateVC: YMKMapInputListener {
    func onMapTap(with map: YMKMap, point: YMKPoint) {
//        let placemark = YMKPlacemarkMapObject()
//        placemark.useAnimation()
//        let iconStyle = YMKIconStyle()
//        iconStyle.
//        placemark.setIconStyleWith(

        let placemark = map.mapObjects.addPlacemark(with: point, image: UIImage(systemName: "mappin")!)
        placemark.useAnimation()
        placemark.isVisible = false
        placemark.isDraggable = true
        let animation = YMKAnimation(type: .smooth, duration: 0.3)
        placemark.setVisibleWithVisible(true, animation: animation) {
            
        }
        print("asdijasiodjasiodajsdioajsdioas")
    }
    
    func onMapLongTap(with map: YMKMap, point: YMKPoint) {
        print("asdjajiosdijoajiosdjioajidjiajiosdjioajiodjaiosjidoa")
    }
}
