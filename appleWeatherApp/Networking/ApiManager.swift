//
//  ApiManager.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 16.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

enum WeatherData {
    case Success(Weather)
    case Fail(Error)
}

protocol ApiManagerProtocol {
    var urlSession: URLSession { get }
    
    func getWeather(complition: @escaping((WeatherData)->Void))
}

class ApiManager: ApiManagerProtocol {
    
    static let domain = "AppleWeatherApp.com"
    
    var urlSession: URLSession = URLSession(configuration: .default)
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    private func getJsonData(url: URL, complition: @escaping(Data?, URLResponse?, Error?)->Void) {
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                complition(nil, nil, error)
                return
            }
            guard let data = data else {
                complition(nil, nil, error)
                return
            }
            complition(data, response, nil)
        }.resume()
    }
    
    func getWeather(complition: @escaping((WeatherData)->Void)) {
        getJsonData(url: url) { (data, response, error) in
            if let error = error {
                complition(.Fail(error))
                return
            }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data!)
                complition(.Success(weather))
            } catch {
                print(error)
                let userInfo = [
                    NSLocalizedDescriptionKey : NSLocalizedString("fail", value: "incorrect data", comment: "")
                ]
                let error = NSError(domain: ApiManager.domain, code: 202, userInfo: userInfo)
                complition(.Fail(error))
            }
        }
    }
}
