//
//  CLLocation + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 05.09.2021.
//

import MapKit

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        let geocoder = CLGeocoder()
        print("asdiojadsioasdijojaoisd: ", self)
        geocoder.reverseGeocodeLocation(self, completionHandler: { placemark, error in
            print("asdiojasodijasd: ", self, placemark, error)
            completion(placemark?.first?.locality, placemark?.first?.country, error)
        })
    }
}
