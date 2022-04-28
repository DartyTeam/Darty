//
//  CLLocation + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 05.09.2021.
//

import MapKit

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ location: CLLocation?, _ error: Error?) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self, completionHandler: { placemark, error in
            completion(placemark?.first?.locality, placemark?.first?.country, placemark?.first?.location, error)
        })
    }
}
