//
//  SelectLocationVC.swift
//  Darty
//
//  Created by Руслан Садыков on 01.08.2021.
//

import UIKit
import MapKit
import CoreLocation

final class SelectLocationVC: UIViewController {
    
    struct CurrentLocationListener {
        let once: Bool
        let action: (CLLocation) -> ()
    }
    
    public typealias CompletionHandler = (Location?) -> ()
    
    public var completion: CompletionHandler?
    
    // regididSeton distance to be used for creation region when user selects place from search results
    public var resultRegionDistance: CLLocationDistance = 600
    
    /// default: true
    public var showCurrentLocationInitially = true

    /// default: false
    /// Select current location only if `location` property is nil.
    public var selectCurrentLocationInitially = true
    
    /// see `region` property of `MKLocalSearchRequest`
    /// default: false
    public var useCurrentLocationAsHint = false
    
    public var searchBarPlaceholder = "Искать"
    public var searchHistoryLabel = "История поиска"
    public var selectButtonTitle = "Выбрать"
    
    public var mapType: MKMapType = .standard {
        didSet {
            if isViewLoaded { mapView.mapType = mapType }
        }
    }
    
    public var location: Location? {
        didSet {
            if isViewLoaded {
                searchController.searchBar.text = location.flatMap { $0.title } ?? ""
                updateAnnotation()
            }
        }
    }
    
    static let SearchTermKey = "SearchTermKey"
    
    let historyManager = SearchHistoryManager()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var localSearch: MKLocalSearch?
    var searchTimer: Timer?
    
    var currentLocationListeners: [CurrentLocationListener] = []
    
    lazy var mapView: MKMapView = {
        $0.mapType = mapType
        $0.showsCompass = false
        $0.showsScale = true
        
        return $0
    }(MKMapView())
    
    lazy var scaleView: MKScaleView = {
        $0.scaleVisibility = .visible
        return $0
    }(MKScaleView(mapView: mapView))
    
    lazy var locationButton: UIButton = {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.maskToBounds = true
        $0.cornerRadius = 22
        $0.setImage(UIImage(systemName: "location.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal), for: .normal)
        $0.addTarget(self, action: #selector(LocationPickerViewController.currentLocationPressed),
                         for: .touchUpInside)
        return $0
    }(UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)))
    
    lazy var results: LocationSearchResultsViewController = {
        let results = LocationSearchResultsViewController()
        results.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
        results.searchHistoryLabel = self.searchHistoryLabel
        return results
    }()
    
    lazy var searchController: UISearchController = {
        $0.searchResultsUpdater = self
        $0.searchBar.delegate = self
        $0.dimsBackgroundDuringPresentation = true
        /// true if search bar in tableView header
        $0.hidesNavigationBarDuringPresentation = true
        $0.searchBar.placeholder = searchBarPlaceholder
        $0.searchBar.barStyle = .black
        $0.searchBar.searchBarStyle = .minimal
        $0.searchBar.textField?.textColor = UIColor(hex: 0xf4f4f4)
        $0.searchBar.textField?.setPlaceHolderTextColor(UIColor(hex: 0xf8f8f8))
        $0.searchBar.textField?.clearButtonMode = .whileEditing
        return $0
    }(UISearchController(searchResultsController: results))
    
    private var setuppedParty: SetuppedParty
    
    init(setuppedParty: SetuppedParty) {
        self.setuppedParty = setuppedParty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        searchTimer?.invalidate()
        localSearch?.cancel()
        geocoder.cancelGeocode()
        // http://stackoverflow.com/questions/32675001/uisearchcontroller-warning-attempting-to-load-the-view-of-a-view-controller/
        let _ = searchController.view
    }
    
    public override func loadView() {
        view = mapView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        
        mapView.addSubview(locationButton)
        
        locationManager.delegate = self
        mapView.delegate = self
        
        // gesture recognizer for adding by tap
        let locationSelectGesture = UITapGestureRecognizer(
            target: self, action: #selector(addLocation(_:)))
        locationSelectGesture.delegate = self
        mapView.addGestureRecognizer(locationSelectGesture)
        
        // user location
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = showCurrentLocationInitially
        
        if useCurrentLocationAsHint {
            getCurrentLocation()
        }
    }
    
    private func setupNavBar() {
        setNavigationBar(withColor: .systemPurple, title: "Выбор местоположения")
        navigationItem.searchController = searchController
        let cancelIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let cancelIconImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: cancelIconConfig)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelIconImage, style: .plain, target: self, action: #selector(cancleAction))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    var presentedInitialLocation = false
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize.height = UIScreen.main.bounds.height
        
        locationButton.frame.origin = CGPoint(
            x: view.frame.width - locationButton.frame.width - 20,
            y: view.frame.height - locationButton.frame.height - 32
        )
        
        // setting initial location here since viewWillAppear is too early, and viewDidAppear is too late
        if !presentedInitialLocation {
            setInitialLocation()
            presentedInitialLocation = true
        }
    }
    
    func setInitialLocation() {
        if let location = location {
            // present initial location if any
            self.location = location
            showCoordinates(location.coordinate, animated: false)
            return
        } else if showCurrentLocationInitially || selectCurrentLocationInitially {
            if selectCurrentLocationInitially {
                let listener = CurrentLocationListener(once: true) { [weak self] location in
                    if self?.location == nil { // user hasn't selected location still
                        self?.selectLocation(location: location)
                    }
                }
                currentLocationListeners.append(listener)
            }
            showCurrentLocation(false)
        }
    }
    
    func getCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func currentLocationPressed() {
        showCurrentLocation()
    }
    
    func showCurrentLocation(_ animated: Bool = true) {
        let listener = CurrentLocationListener(once: true) { [weak self] location in
            self?.showCoordinates(location.coordinate, animated: animated)
            self?.addLocation(coordinates: location.coordinate)
        }
        currentLocationListeners.append(listener)
        getCurrentLocation()
    }
    
    func updateAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        if let location = location {
            mapView.addAnnotation(location)
            mapView.selectAnnotation(location, animated: true)
        }
    }
    
    func showCoordinates(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: resultRegionDistance, longitudinalMeters: resultRegionDistance)
        mapView.setRegion(region, animated: animated)
    }

    func selectLocation(location: CLLocation) {
        // add point annotation to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(location) { response, error in
            if let error = error as NSError?, error.code != 10 { // ignore cancelGeocode errors
                // show error and remove annotation
                let alert = UIAlertController(style: .alert, title: nil, message: error.localizedDescription)
                alert.addAction(title: "OK", style: .cancel) { action in
                    self.mapView.removeAnnotation(annotation)
                }
                alert.show()

            } else if let placemark = response?.first {
                // get POI name from placemark if any
                let name = placemark.areasOfInterest?.first

                // pass user selected location too
                self.location = Location(name: name, location: location, placemark: placemark)
                
                let address = Address(placemark: placemark)
                annotation.title = address.line1
                annotation.subtitle = address.line2
            } else {
                let placemark = MKPlacemark(coordinate: location.coordinate)
                                
                // pass user selected location too
                self.location = Location(name: "Координаты выбраны", location: location, placemark: placemark)
                
                annotation.title = "Координаты выбраны"
                annotation.subtitle = "Координаты выбраны"
            }
        }
    }
    
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension SelectLocationVC: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocationListeners.forEach { $0.action(location) }
        currentLocationListeners = currentLocationListeners.filter { !$0.once }
        manager.stopUpdatingLocation()
    }
}

// MARK: Searching

extension SelectLocationVC: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let term = searchController.searchBar.text else { return }
        
        searchTimer?.invalidate()

        let searchTerm = term.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if searchTerm.isEmpty {
            results.locations = historyManager.history()
            results.isShowingHistory = true
            results.tableView.reloadData()
        } else {
            // clear old results
            showItemsForSearchResult(nil)
            
            searchTimer = Timer.scheduledTimer(timeInterval: 0.2,
                target: self, selector: #selector(LocationPickerViewController.searchFromTimer(_:)),
                userInfo: [LocationPickerViewController.SearchTermKey: searchTerm],
                repeats: false)
        }
    }
    
    @objc func searchFromTimer(_ timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: AnyObject],
            let term = userInfo[LocationPickerViewController.SearchTermKey] as? String
            else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        
        if let location = locationManager.location, useCurrentLocationAsHint {
            request.region = MKCoordinateRegion(center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        }
        
        localSearch?.cancel()
        localSearch = MKLocalSearch(request: request)
        localSearch!.start { response, _ in
            self.showItemsForSearchResult(response)
        }
    }
    
    func showItemsForSearchResult(_ searchResult: MKLocalSearch.Response?) {
        results.locations = searchResult?.mapItems.map { Location(name: $0.name, placemark: $0.placemark) } ?? []
        results.isShowingHistory = false
        results.tableView.reloadData()
    }
    
    func selectedLocation(_ location: Location) {
        // dismiss search results
        dismiss(animated: true) {
            // set location, this also adds annotation
            self.location = location
            self.showCoordinates(location.coordinate)
            
            self.historyManager.addToHistory(location)
        }
    }
}

// MARK: Selecting location with gesture

extension SelectLocationVC {
    @objc func addLocation(_ gestureRecognizer: UIGestureRecognizer) {
        
//        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
            addLocation(coordinates: coordinates)
//        }
    }
    
    private func addLocation(coordinates: CLLocationCoordinate2D) {

        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        // clean location, cleans out old annotation too
        self.location = nil
        selectLocation(location: location)
    }
}

// MARK: MKMapViewDelegate

extension SelectLocationVC: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        pin.pinTintColor = UIColor(hex: 0xFF2DC6)

        pin.animatesDrop = true
        pin.rightCalloutAccessoryView = selectLocationButton()
        pin.canShowCallout = true
        return pin
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let location = location {
            self.mapView.selectAnnotation(location, animated: false)
        }
    }
    
    func selectLocationButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        button.setTitle(selectButtonTitle, for: UIControl.State())
        if let titleLabel = button.titleLabel {
            let width = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
            button.frame.size = CGSize(width: width + 10, height: 30.0)
        }
        button.backgroundColor = UIColor(hex: 0x007AFF)
        button.setTitleColor(.white, for: UIControl.State())
        button.borderWidth = 2
        button.borderColor = UIColor(hex: 0x007AFF)
        button.cornerRadius = 5
        button.titleEdgeInsets.left = 5
        button.titleEdgeInsets.right = 5
        return button
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        startLoading()
        setuppedParty.address = location?.address ?? ""
        setuppedParty.latitude = Double((location?.coordinate.latitude)!)
        setuppedParty.longitude = Double((location?.coordinate.longitude)!)
        setuppedParty.city = ""
        FirestoreService.shared.savePartyWith(party: setuppedParty) { [weak self] (result) in
            switch result {
            
            case .success(_):
                self?.stopLoading()
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
                self?.stopLoading()
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        let pins = mapView.annotations.filter { $0 is MKPinAnnotationView }
//        assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")
//
//        if let userPin = views.first(where: { $0.annotation is MKUserLocation }) {
//            userPin.canShowCallout = false
//        }
    }
}

extension SelectLocationVC: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UISearchBarDelegate

extension SelectLocationVC: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // dirty hack to show history when there is no text in search bar
        // to be replaced later (hopefully)
        if let text = searchBar.text, text.isEmpty {
            searchBar.text = " "
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // remove location if user presses clear or removes text
        if searchText.isEmpty {
            location = nil
            searchBar.text = " "
        }
    }
}

