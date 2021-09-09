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
    case locationMessage
}

final class MapVC: UIViewController {
    
    private var mapType: MapType = .aboutParty
    
    private lazy var mapManager: MapManager = {
        let mapManager = MapManager()
        mapManager.alertDelegate = self
        return mapManager
    }()
    
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
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let timeAndDistanceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var userLocationButton: UIButton = {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.maskToBounds = true
        $0.cornerRadius = 22
        $0.setImage(UIImage(systemName: "location.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal), for: UIControl.State())
        $0.addTarget(self, action: #selector(centerViewInUserLocation),
                         for: .touchUpInside)
        return $0
    }(UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)))
    
    private let navigateInAnotherAppButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.cornerRadius = 22
        button.maskToBounds = true
        button.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal), for: UIControl.State())
        button.addTarget(self, action: #selector(navigateInAnotherApp), for: .touchUpInside)
        return button
    }()
    
    private lazy var goButton: UIButton = {
        let button = UIButton()
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 32, weight: .bold))
        button.setImage(UIImage(systemName: "location.north.fill", withConfiguration: boldConfig)?.withTintColor(accentColor, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var accentColor: UIColor = .systemOrange
    private var party: PartyModel?
    private var location = CLLocation(latitude: 0, longitude: 0)
    
    // MARK: - Lifecycle
    init(party: PartyModel) {
        self.party = party
        super.init(nibName: nil, bundle: nil)
        mapType = .aboutParty
    }
    
    init(location: CLLocation) {
        super.init(nibName: nil, bundle: nil)
        self.location = location
        mapType = .locationMessage
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
        timeAndDistanceLabel.text = ""
        
        mapManager.checkLocationServices(mapView: mapView, type: .aboutParty) {
            mapManager.locationManager.delegate = self
        }
        
        if mapType == .aboutParty, let party = party {
            mapManager.setupPartymark(party: party, mapView: mapView)
        } else {
            mapManager.setupLocationMark(location: location, mapView: mapView)
        }
        
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
    
    @objc private func navigateInAnotherApp() {
        showQuestionAnotherApp(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    private func showQuestionAnotherApp(lat: Double, lon: Double) {
        let alert = UIAlertController(title: "Построить маршрут?", message: nil, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.showListAnotherApps(lat: lat, lon: lon)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showListAnotherApps(lat: Double, lon: Double) {
        let alert = UIAlertController(title: "Выберите приложение", message: nil, preferredStyle: .actionSheet)
        
        let googleMapsUrl = URL(string:"comgooglemaps://")!
        let yandexMapsUrl = URL(string:"yandexmaps://")!
        let appleMapsUrl = URL(string: "http://maps.apple.com")!
        let dgisMapsUrl = URL(string: "dgis://")!
        
        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { (_) in
            
            
            if (UIApplication.shared.canOpenURL(googleMapsUrl)) {
                UIApplication.shared.open(URL(string:
                                                    "comgooglemaps://?saddr=&daddr=\(String(describing: lat)),\(String(describing: lon))")!)
            } else {
                UIApplication.shared.open(URL(string:
                                                    "https://www.google.co.in/maps/dir/?saddr=&daddr=\(String(describing: lat)),\(String(describing: lon))")!)
            }
        }
        
        let yandexAction = UIAlertAction(title: "Яндекс Карты", style: .default) { (_) in
            
            if (UIApplication.shared.canOpenURL(yandexMapsUrl)) {
                UIApplication.shared.open(URL(string:
                                                    "yandexmaps://maps.yandex.ru/?rtext=\(String(describing: self.previousLocation?.coordinate.latitude)),\(String(describing: self.previousLocation?.coordinate.longitude))~\(String(describing: lat)),\(String(describing: lon))&rtt=mt")!)
                
            } else {
                UIApplication.shared.open(URL(string:
                                                    "https://maps.yandex.ru/?rtext=\(String(describing: self.previousLocation?.coordinate.latitude)),\(String(describing: self.previousLocation?.coordinate.longitude))~\(String(describing: lat)),\(String(describing: lon))&rtt=mt")!)
            }
        }
        
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { _ in
            if (UIApplication.shared.canOpenURL(appleMapsUrl)) {
                UIApplication.shared.open(URL(string: "http://maps.apple.com/?sll=\(lat),\(lon)&z=10&t=s")!)
            } else {
              NSLog("Can't use Apple Maps");
            }
        }
     
        let dgisMapsAction = UIAlertAction(title: "2ГИС", style: .default) { (_) in
            
            if (UIApplication.shared.canOpenURL(dgisMapsUrl)) {
                UIApplication.shared.open(URL(string: "dgis://2gis.ru/routeSearch/rsType/car/to/\(lon),\(lat)")!)
            } else {
                UIApplication.shared.open(URL(string:
                                                "https://itunes.apple.com/ru/app/id481627348?mt=8")!)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(googleAction)
        alert.addAction(yandexAction)
        alert.addAction(appleMapsAction)
        alert.addAction(dgisMapsAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
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
        mapView.addSubview(navigateInAnotherAppButton)
        
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
            make.trailing.equalToSuperview().offset(-32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-96)
            make.size.equalTo(44)
        }
        
        navigateInAnotherAppButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-32)
            make.bottom.equalTo(userLocationButton.snp.top).offset(-32)
            make.size.equalTo(44)
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

extension MapVC: MapManagerAlertDelegate {
    func showDirectionsError(_ error: String) {
        let alert = UIAlertController(title: error, message: "Вы можете простроить маршрут в другой программе", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Построить в другой программе", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.showQuestionAnotherApp(lat: self.location.coordinate.latitude, lon: self.location.coordinate.longitude)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String?) {
        self.showAlert(title: title, message: message ?? "")
    }
}
