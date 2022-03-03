//
//  MapManager.swift
//  Darty
//
//  Created by Руслан Садыков on 01.08.2021.
//

import UIKit
import MapKit

protocol MapManagerAlertDelegate {
    func showAlert(title: String, message: String?)
    func showDirectionsError(_ error: String)
}

class MapManager {
    
    let locationManager = CLLocationManager()
    private var destinationCoordinate: CLLocationCoordinate2D?
    private let regionImMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    var alertDelegate: MapManagerAlertDelegate?
    
    // Установка маркера вечеринки
    func setupPartymark(party: PartyModel, mapView: MKMapView) {
        
       // guard let location = party.location else { return }
        #warning("Вместо геокодера адреса можно использовать имеющиеся координаты")
        let location = party.address
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (partymarks, error) in
            
            // Если объект error не содержит nil
            if let error = error {
                print(error)
                return
            }
            
            guard let partymarks = partymarks else { return }
            
            let partymark = partymarks.first
            
            let annotation = MKPointAnnotation()
            
            annotation.title = party.name
            annotation.subtitle = party.type
            
            guard let partymarkLocation = partymark?.location else { return }
            
            annotation.coordinate = partymarkLocation.coordinate
            self.destinationCoordinate = partymarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Установка маркера вечеринки
    func setupLocationMark(location: CLLocation, mapView: MKMapView) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        self.destinationCoordinate = location.coordinate
    }
    
    func checkSearchLocation(location: String, mapView: MKMapView) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] (partymarks, error) in
            
            if let error = error {
                print("Geocoding error: ", error)
                return
            }
            
            guard let partymarks = partymarks else { return }
            let partymark = partymarks.first
            
            guard let partymarkLocation = partymark?.location else { return }
            
            self?.destinationCoordinate = partymarkLocation.coordinate
            
//            mapView.setCenter(partymarkLocation.coordinate, animated: true)
            
            let region = MKCoordinateRegion( center: partymarkLocation.coordinate, latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
    }
    
    // Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, type: MapType, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() { //Данный метод является методом класса и поэтому мы обращаемся к классу, а не к его экземпляру locationManager
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, type: type)
            closure()
        } else {
            self.alertDelegate?.showAlert(title: "Отключены службы геолокации", message: "Для включения перейдите: Настройки -> Конфиденциальность -> Службы геолокации -> Включить")
        }
    }
    
    // Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, type: MapType) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
//            if type == .createPaty { showUserLocation(mapView: mapView) }
            break
        case .denied:
            // Делаем отсрочку показа Alert на 1 секунду иначе он прогрузится раньше нужного из-за вызова метода из viewDidLoad и не отобразится
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertDelegate?.showAlert(title: "Отсутствует разрешение на определение местоположения", message: "Для выдачи разрешения перейдите: Настройки -> Конфиденциальность -> Службы геолокации -> PartyMaker -> При использовании приложения")
            }
            break
        case .restricted, .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("new case is Available")
        }
    }

    // Фокус карты на местоположение пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation,
                                            latitudinalMeters: regionImMeters,
                                            longitudinalMeters: regionImMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Построение маршрута от местоположения пользователя до заведения
    func getDirection(for mapView: MKMapView, previousLocation: (CLLocation) -> (), getTimeAndDistance: @escaping (String) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            alertDelegate?.showAlert(title: "Ошибка", message: "Не удалость определить ваше местоположение")
            return
        }
        
        locationManager.startUpdatingLocation() // Постоянное отслеживание местоположения пользователя
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            alertDelegate?.showAlert(title: "Ошибка", message: "Место назначения не найдено")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(mapView: mapView, withNew: directions)
        
        directions.calculate { (response, error) in
            
            if let error = error {
                print("ERROR_LOG Error in calculate directions: ", error)
                self.alertDelegate?.showDirectionsError(error.localizedDescription)
                return
            }
            
            guard let response = response else {
                self.alertDelegate?.showAlert(title: "Ошибка", message: "Маршрут не доступен")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f",route.distance / 1000)
                let timeInterval = String(format: "%", route.expectedTravelTime / 60)
                
                let timeAndDistance = "Расстояние до места: \(distance) км.\n Время в пути: \(timeInterval) м."
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    getTimeAndDistance(timeAndDistance)
                }
            }
        }
    }
    
    // Метод отменяет все действующие маршруты и удаляет их с карты
    func resetMapView(mapView: MKMapView, withNew directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays) // Удаление всех наложений с карты
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() } // Отменем маршрут у каждого элемента массива
        directionsArray.removeAll() // Удаляем все элементы массива
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = destinationCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Изменение отображаемой зоны области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView,
                                   and location: CLLocation?,
                                   closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
