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

final class CityAndCountrySetupProfileVC: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let aboutText = "Страна и город вашего местонахождения"
        static let textFont: UIFont? = .sfProDisplay(ofSize: 26, weight: .semibold)
        
        static let cityFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
        static let countryFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
        
        static let cityPlaceholder = "Город неизвестен"
        static let countryPlaceholder = "Страна неизвестна"
    }
    
    // MARK: - UI Elements
    let locationManager = CLLocationManager()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let aboutTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.aboutText
        label.font = Constants.textFont
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(checkLocationServices), for: .touchUpInside)
        button.setTitle("Запросить местоположение", for: UIControl.State())
        button.setImage(UIImage(systemName: "location.fill"), for: UIControl.State())
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 16)
        button.tintColor = .white
        return button
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.countryFont
        label.text = Constants.countryPlaceholder
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.cityFont
        label.text = Constants.cityPlaceholder
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Properties
    private var city: String?
    private var country: String?
    
    // MARK: - Delegate
    weak var delegate: CityAndCountrySetupProfileDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        setNavigationBar(withColor: .systemBlue, title: "О вас")
        setupViews()
        setupConstraints()
    }
    
    @objc private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() { //Данный метод является методом класса и поэтому мы обращаемся к классу, а не к его экземпляру locationManager
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        } else {
            self.showAlert(title: "Отключены службы геолокации", message: "Для включения перейдите: Настройки -> Конфиденциальность -> Службы геолокации -> Включить")
        }
    }
    
    // Проверка авторизации приложения для использования сервисов геолокации
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("asdijoasjdoijiasdijoasoijdjoiasdoijasd")
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            locationManager.location?.fetchCityAndCountry(completion: { [weak self] city, country, error in
                if let error = error {
                    SPAlert.present(title: error.localizedDescription, message: "Вы можете попробовать снова в настройках аккаунта, а пока будет выбрано - Россия, Москва", preset: .error)
                    self?.city = "Moscow"
                    self?.country = "Russia"
                    self?.countryLabel.text = "Russia"
                    self?.cityLabel.text = "Moscow"
                    return
                }
                
                self?.countryLabel.text = country
                self?.cityLabel.text = city
                self?.city = city
                self?.country = country
            })
            break
        case .denied:
            // Делаем отсрочку показа Alert на 1 секунду иначе он прогрузится раньше нужного из-за вызова метода из viewDidLoad и не отобразится
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Отсутствует разрешение на определение местоположения", message: "Для выдачи разрешения перейдите: Настройки -> Конфиденциальность -> Службы геолокации -> Darty -> При использовании приложения")
            }
            break
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("ERROR_LOG Error check location authorization, new case is Available")
        }
    }
    
    private func setupViews() {
        if let image = UIImage(named: "about.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.75)) {
            addBackground(image)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(aboutTitleLabel)
        view.addSubview(nextButton)
        view.addSubview(countryLabel)
        view.addSubview(cityLabel)
        view.addSubview(retryButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        guard let city = city, let country = country else {
            SPAlert.present(title: "Запросите определение местоположения снова", preset: .error)
            return
        }
        delegate?.goNext(with: city, and: country)
    }
}

// MARK: - Setup constraints
extension CityAndCountrySetupProfileVC {
    
    private func setupConstraints() {
        
        aboutTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.left.right.equalToSuperview().inset(44)
        }
        
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
        
        retryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
    }
}

extension CityAndCountrySetupProfileVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _ = locations.first else { return }
        manager.stopUpdatingLocation()
    }
}
