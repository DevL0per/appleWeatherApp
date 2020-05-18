//
//  MainScreenPresenter.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import CoreLocation

protocol MainScreenPresenterProtocol {
    func getWeather()
}

class MainScreenPresenter: NSObject, MainScreenPresenterProtocol {
    
    var view: MainScreenView!
    
    private var apiManager: ApiManager!
    private let urlManager = URLManager()
    private let locationManager = CLLocationManager()
    private var city: String!
    private var timer: Timer?
    private var isErrorMessageWasShown = false
    
    override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func getWeather() {
        // if intertet switched on
        if Reachability.isConnectedToNetwork() {
            if timer != nil {
                timer!.invalidate()
            }
            apiManager.getWeather {[unowned self] (weather) in
                switch weather {
                case .Success(let weatherData):
                    DispatchQueue.main.async {
                        let mainScreenWeatherModel = self.weatherToMainScreenWeatherModel(weather: weatherData)
                        self.view.displayWeather(mainScreenWeatherModel: mainScreenWeatherModel)
                        
                    }
                case .Fail(let error):
                    DispatchQueue.main.async {
                        self.view.displayErrorMessage(errorMessage: error.localizedDescription)
                    }
                }
            }
        } else {
            if !isErrorMessageWasShown {
                let userInfo = [
                    NSLocalizedDescriptionKey :
                        NSLocalizedString("fail",
                                          value: "Fail loading data, this application requires internet connection",
                                          comment: "")
                ]
                let error = NSError(domain: ApiManager.domain, code: 651, userInfo: userInfo)
                self.view.displayErrorMessage(errorMessage: error.localizedDescription)
                isErrorMessageWasShown = true
                createTimer()
            }
        }
    }
    
    // если интернет отключен он будет спрашивать есть ли соеденение каждые 5 секунд
    private func createTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 5.0,
                                         target: self,
                                         selector: #selector(getWeather),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    private func weatherToMainScreenWeatherModel(weather: Weather) -> MainScreenWeatherModel {
        let mainScreenCurrentWeatherModel =
            MainScreenCurrentWeatherModel(city: city,
                                          temperature: fahrenheitToCelsius(weather.currently.temperature)+"°",
                                          day: String("monday"),
                                          maxTemperature: fahrenheitToCelsius(weather.daily.data[0].temperatureHigh),
                                          minTemperature: fahrenheitToCelsius(weather.daily.data[0].temperatureLow),
                                          sammery: String(weather.currently.summary))
        // hourly weatherModel
        var mainScreenHourlyWeather: [MainScreenHourlyWeatherModel] = []
        let sunriseTime = weather.daily.data[1].sunriseTime
        let sunsetTime = weather.daily.data[0].sunsetTime
        
        
        for weather in weather.hourly.data {
            let mainScreenHourlyWeatherModel =
                MainScreenHourlyWeatherModel(stringTime: weather.getStringTime(),
                                             unixTime: weather.time,
                                             icon: weather.icon,
                                             degrees: fahrenheitToCelsius(weather.temperature)+"°")
            mainScreenHourlyWeather.append(mainScreenHourlyWeatherModel)
        }
        let sunriseTimeWeather = MainScreenHourlyWeatherModel(stringTime: formatSunsetAndSunriseTime(sunriseTime),
                                                              unixTime: sunriseTime,
                                                              icon: "sunrise",
                                                              degrees: "Sunrise")
        let sunsetTimeWeather = MainScreenHourlyWeatherModel(stringTime: formatSunsetAndSunriseTime(sunsetTime),
                                                             unixTime: sunsetTime,
                                                             icon: "sunset",
                                                             degrees: "Sunset")
        mainScreenHourlyWeather.append(sunriseTimeWeather)
        mainScreenHourlyWeather.append(sunsetTimeWeather)
        mainScreenHourlyWeather.sort { (one, two) -> Bool in
            return one.unixTime < two.unixTime
        }
        
        // daily weatherModel
        var mainScreenDailyWeather: [MainScreenDailyWeatherModel] = []
        for weather in weather.daily.data {
            let mainScreenDailyWeatherModel =
                MainScreenDailyWeatherModel(day: weather.getDay(),
                                            icon: weather.icon,
                                            maxTemperature: fahrenheitToCelsius(weather.temperatureHigh),
                                            minTemperature: fahrenheitToCelsius(weather.temperatureLow))
            mainScreenDailyWeather.append(mainScreenDailyWeatherModel)
        }
        
        // main content weatherModel
        let mainContentWeatherModel =
            MainContentWeatherModel(message: weather.daily.data[0].summary,
                                    sunrise: formatSunsetAndSunriseTime(sunriseTime),
                                    sunset: formatSunsetAndSunriseTime(sunsetTime),
                                    chanceOfRain: String(Int(weather.currently.precipProbability*100))+"%",
                                    humidity: String(Int(weather.currently.humidity*100))+"%",
                                    wind: "w "+String(weather.currently.windSpeed)+" km/h",
                                    feelsLike: fahrenheitToCelsius(weather.currently.apparentTemperature)+"°",
                                    precipitation: String(weather.currently.precipIntensity)+" cm",
                                    pressure: String(weather.currently.pressure)+" hPa",
                                    visiblity: String(weather.currently.visibility)+" km",
                                    uvIndex: String(weather.currently.uvIndex))
        let mainScreenWeatherModel = MainScreenWeatherModel(mainScreenCurrentWeatherModel: mainScreenCurrentWeatherModel,
                                                            mainContentWeatherModel: mainContentWeatherModel, mainScreenHourlyWeatherModel: mainScreenHourlyWeather, mainScreenDailyWeatherModel: mainScreenDailyWeather)
        return mainScreenWeatherModel
    }
    
    private func fahrenheitToCelsius(_ temperature: Double) -> String {
        return String(Int((temperature-32)/(9/5)))
    }

    private func formatSunsetAndSunriseTime(_ unixDate: Double) -> String {
        let date = Date(timeIntervalSince1970: unixDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
    
    
}

extension MainScreenPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let url = urlManager.getURL(latitude: String(location.coordinate.latitude),
                                        longitude: String(location.coordinate.longitude))!
            apiManager = ApiManager(url: url)
            location.fetchCity { [unowned self] (city, error)  in
                if let city = city {
                    self.city = city
                } else {
                    self.city = "Not Found"
                }
                self.getWeather()
            }
        }
    }
}
