//
//  Extension+CLLocation.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 17.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit
import MapKit

extension CLLocation {
    func fetchCity(completion: @escaping (_ city: String?,_ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $1) }
    }
}
