//
//  CityAndCountrySetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 05.09.2021.
//

import UIKit
import FirebaseAuth
import MapKit
import SPAlert
import FlyoverKit
import SafeSFSymbols
import Inject

final class CityAndCountrySetupProfileVC: UIViewController {

    private struct CityAndCountry {
        var city: String?
        var country: String?
    }

    // MARK: - Constants
    private enum Constants {
        static let textFont: UIFont? = .sfProDisplay(ofSize: 26, weight: .semibold)
        static let cityFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
        static let countryFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
        static let userLocationButtonSize: CGFloat = 56
    }
    
    // MARK: - UI Elements
    private let locationManager = CLLocationManager()
    
    private lazy var nextButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.countryFont
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.cityFont
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var userLocationButton: UIButton = {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = Constants.userLocationButtonSize / 2
        $0.setImage(
            UIImage(SPSafeSymbol.location.circleFill)
                .withTintColor(.systemPurple, renderingMode: .alwaysOriginal),
            for: UIControl.State()
        )
        $0.addTarget(self, action: #selector(checkLocationServices), for: .touchUpInside)
        $0.addBlurEffect()
        return $0
    }(UIButton())

    private let flyoverMapView = FlyoverMapView()

    // MARK: - Properties
    private var cityAndCountry = CityAndCountry() {
        didSet {
            cityLabel.text = cityAndCountry.city
            countryLabel.text = cityAndCountry.country
            nextButton.backgroundColor = (cityAndCountry.country != nil && cityAndCountry.city != nil) ? nextButton.enabledBackground : nextButton.disabledBackround
        }
    }
    
    // MARK: - Delegate
    weak var delegate: CityAndCountrySetupProfileDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setupFlyover()
        setupViews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(withColor: .systemBlue, title: "Страна и город")
        checkLocationServices()
    }

    private func setupFlyover() {
        let randomAwesomeLocation = FlyoverAwesomePlace.allCases.randomElement()
        flyoverMapView.start(flyover: randomAwesomeLocation!)
        view.addSubview(flyoverMapView)
        flyoverMapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        } else {
            SPAlert.present(
                title: "Отключены службы геолокации",
                message: "Для включения перейдите: Настройки -> Конфиденциальность -> Службы геолокации -> Включить",
                preset: .error
            )
        }
    }
    
    // Проверка авторизации приложения для использования сервисов геолокации
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            setCurrentLocation()
        case .denied:
            let alertVC = UIAlertController(title: "Отключены службы геолокации", message: "Необходимо разрешить доступ в настройках", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Перейти в настройки", style: .default) { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertVC.addAction(settingsAction)
            present(alertVC, animated: true)
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("ERROR_LOG Error check location authorization, new case is Available")
        }
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(nextButton)
        view.addSubview(countryLabel)
        view.addSubview(cityLabel)
        view.addSubview(userLocationButton)
    }

    // MARK: - Functions
    private func setCurrentLocation() {
        locationManager.startUpdatingLocation()
        locationManager.location?.fetchCityAndCountry(completion: { [weak self] city, country, location, error in
            guard let self = self else { return }
            if let location = location, city != self.cityAndCountry.city, country != self.cityAndCountry.country {
                self.flyoverMapView.start(flyover: location)
            }
            if let error = error {
                self.cityAndCountry.city = "Москва"
                self.cityAndCountry.country = "Россия"
                let messageText = "Вы можете попробовать снова в настройках аккаунта, а пока будет выбрано - \(self.cityAndCountry.country!), \(self.cityAndCountry.city!)"
                SPAlert.present(
                    title: error.localizedDescription,
                    message: messageText,
                    preset: .error
                )
                return
            } else if let city = city, let country = country {
                self.cityAndCountry.city = city
                self.cityAndCountry.country = country
            }
        })
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        guard let city = cityAndCountry.city, let country = cityAndCountry.country else {
            SPAlert.present(title: "Запросите определение местоположения снова", preset: .error)
            return
        }
        delegate?.goNext(with: city, and: country)
    }
}

// MARK: - Setup constraints
extension CityAndCountrySetupProfileVC {
    private func setupConstraints() {
        countryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-32)
            make.left.right.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        cityLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
        }
        
        userLocationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
            make.size.equalTo(Constants.userLocationButtonSize)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CityAndCountrySetupProfileVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _ = locations.first else { return }
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
        setCurrentLocation()
    }
}
