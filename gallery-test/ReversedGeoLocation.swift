//
//  ReversedGeoLocation.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 09.07.2022.
//

import Foundation
import CoreLocation

struct ReversedGeoLocation {
    let city: String
    let country: String

    init(with placemark: CLPlacemark) {
        self.city           = placemark.locality ?? ""
        self.country        = placemark.country ?? ""
    }
}
