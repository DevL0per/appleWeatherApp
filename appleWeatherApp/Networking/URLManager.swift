//
//  URLManager.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 16.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import Foundation

//create URL for request
struct URLManager {
    let baseURL = URL(string: "https://api.darksky.net/forecast/")
    let key = "048f56ba3bfbe5071076e03130702999/"
    
    func getURL(latitude: String, longitude: String) -> URL? {
        let path = key+latitude+","+longitude
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        return url
    }
}
