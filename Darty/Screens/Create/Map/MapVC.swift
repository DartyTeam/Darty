//
//  MapVC.swift
//  Darty
//
//  Created by Руслан Садыков on 01.08.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

enum MapType {
    case aboutParty
}

final class MapVC: UIViewController {
    
    private lazy var searchController: UISearchController = {
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
    
    private lazy var results: LocationSearchResultsViewController = {
        let results = LocationSearchResultsViewController()
        results.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
        results.searchHistoryLabel = self.searchHistoryLabel
        return results
    }()
    
    private var searchTimer: Timer?
    private var localSearch: MKLocalSearch?
    private let historyManager = SearchHistoryManager()
    private var searchBarPlaceholder = "Искать"
    private var searchHistoryLabel = "История поиска"
    
    // regididSeton distance to be used for creation region when user selects place from search results
    private var resultRegionDistance: CLLocationDistance = 600
    
    /// see `region` property of `MKLocalSearchRequest`
    /// default: false
    private var useCurrentLocationAsHint = false
    
    private func selectedLocation(_ location: Location) {
        // dismiss search results
        dismiss(animated: true) {
            // set location, this also adds annotation
            self.location = location
            self.showCoordinates(location.coordinate)
            
            self.historyManager.addToHistory(location)
        }
    }
    public var location: Location? {
        didSet {
            if isViewLoaded {
                searchController.searchBar.text = location.flatMap { $0.title } ?? ""
            }
        }
    }
    private func showCoordinates(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: resultRegionDistance, longitudinalMeters: resultRegionDistance)
        mapView.setRegion(region, animated: animated)
    }

    
    
    
    
    
    
    
    
    
    private let mapManager = MapManager()
    private var mapViewControllerDelegate: MapViewControllerDelegate?
    
    private let annotationIdentifier = "annotationIdentifier"
    
    private var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    private let mapView = MKMapView()
    
    private let mapMarkerImage = UIImageView(image: UIImage(systemName: "mappin"))
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let timeAndDistanceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var userLocationButton: UIButton = {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.maskToBounds = true
        $0.cornerRadius = 22
        $0.setImage(UIImage(systemName: "location.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal).rotate(radians: .pi / 3), for: .normal)
        $0.addTarget(self, action: #selector(centerViewInUserLocation),
                         for: .touchUpInside)
        return $0
    }(UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)))
    
    private lazy var goButton: UIButton = {
        let button = UIButton()
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 32, weight: .bold))
        button.setImage(UIImage(systemName: "location.north.fill", withConfiguration: boldConfig)?.withTintColor(accentColor, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var accentColor: UIColor = .systemOrange
    private var party: PartyModel
    
    // MARK: - Lifecycle
    init(party: PartyModel) {
        self.party = party
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        
        setupNavBar()
        setupMapView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
    }
    
    private func setupNavBar() {
        setNavigationBar(withColor: accentColor, title: "Местоположение")
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        timeAndDistanceLabel.isHidden = true
        timeAndDistanceLabel.text = ""
        
        mapManager.checkLocationServices(mapView: mapView, type: .aboutParty) {
            mapManager.locationManager.delegate = self
        }
        
        mapManager.setupPartymark(party: party, mapView: mapView)
        mapMarkerImage.isHidden = true
        addressLabel.isHidden = true
        goButton.isHidden = false
        timeAndDistanceLabel.isHidden = false
    }
    
    // MARK: - Handlers
    @objc private func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @objc private func goButtonPressed() {
        
        mapManager.getDirection(for: mapView) { (location) in
            previousLocation = location
        } getTimeAndDistance: { (timeAndDistance) in
            self.timeAndDistanceLabel.text = timeAndDistance
        }
    }
    
    deinit {
        print("deinit", MapVC.self)
    }
}

// MARK: - Setup constraints
extension MapVC {
    
    private func setupConstraints() {
        
        view.addSubview(mapView)
        mapView.addSubview(goButton)
        mapView.addSubview(userLocationButton)
        mapView.addSubview(timeAndDistanceLabel)
        mapView.addSubview(addressLabel)
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        timeAndDistanceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(128)
            make.centerX.equalToSuperview()
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(128)
            make.centerX.equalToSuperview()
        }
        
        goButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-88)
            make.centerX.equalToSuperview()
        }
        
        userLocationButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-44)
            make.bottom.equalToSuperview().offset(-124)
        }
        
        mapMarkerImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
            
            annotationView?.canShowCallout = true // Включение отображения
        }
        
        // ToDO add image to party
        //        if let imageData = party.imageUrlString {
        //            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        //            imageView.layer.cornerRadius = 10
        //            imageView.clipsToBounds = true
        //            imageView.image = UIImage(data: imageData)
        //            annotationView?.rightCalloutAccessoryView = imageView
        //        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode() // Для оптимизации
        geocoder.reverseGeocodeLocation(center) { (partymarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let partymarks = partymarks else { return }
            
            let partymark = partymarks.first
            let streetName = partymark?.thoroughfare
            let buildNumber = partymark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    // Для отображения наложения маршрута его необходимо отрендерить
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemOrange
        
        return renderer
    }
}

// MARK: - CLLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {
    
    // Данный метод вызывается при каждом изменении статуса авторизации приложения для использования служб геолокации
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView,
                                              type: .aboutParty)
    }
}

extension MapVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
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
        
        if let location = mapManager.locationManager.location, useCurrentLocationAsHint {
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
}

// MARK: UISearchBarDelegate
extension MapVC: UISearchBarDelegate {
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
