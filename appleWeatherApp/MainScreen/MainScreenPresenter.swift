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
    func getSavedData()
}

class MainScreenPresenter: NSObject, MainScreenPresenterProtocol {
    
    var view: MainScreenView!
    
    private var apiManager: ApiManager!
    private let urlManager = URLManager()
    private let locationManager = CLLocationManager()
    private var city: String!
    private var timer: Timer?
    private var isErrorMessageWasShown = false
    private var isgetWeatherFinished = false
    
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
            // trying to get data from internet
            apiManager.getWeather {[unowned self] (weather) in
                switch weather {
                case .Success(let weatherData):
                    let mainScreenWeatherModel = self.weatherToMainScreenWeatherModel(weather: weatherData)
                    self.saveDataInUserDefaults(data: mainScreenWeatherModel)
                    DispatchQueue.main.async {
                        self.findBackroundColorToMainScreen(iconName:
                            mainScreenWeatherModel.mainScreenHourlyWeatherModel[0].icon)
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
                createErrorMessage(value: "Fail loading data, this application requires internet connection",
                                   code: 651)
                isErrorMessageWasShown = true
                createTimer()
            }
        }
    }
    
    private func findBackroundColorToMainScreen(iconName: String) {
        var backgroundColorCase: BackgroundColorCase!
        switch iconName {
        case "clear-day", "sunset", "sunrise", "partly-cloudy-day":
            backgroundColorCase = .day
        case "clear-night", "partly-cloudy-night":
            backgroundColorCase = .night
        case "rain", "snow", "sleet", "wind", "fog":
            backgroundColorCase = .precipitation
        case "cloudy":
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 6..<12:
                backgroundColorCase = .day
            default:
                backgroundColorCase = .night
            }
        default:
            backgroundColorCase = .day
        }
        UserDefaultsManager.shared.saveBackroundColor(backgroundColorCase: backgroundColorCase.rawValue)
        view.setBackroundColor(bacgroundColorCase: backgroundColorCase)
    }
    
    // save data from intenet to userDefault
    private func saveDataInUserDefaults(data: MainScreenWeatherModel) {
        let queue = DispatchQueue(label: "userDefaultsQueue", qos: .background, attributes: .concurrent)
        queue.async {
            UserDefaultsManager.shared.saveWeaher(weaherViewModel: data)
        }
    }
    
    private func createErrorMessage(value: String, code: Int) {
        let userInfo = [
            NSLocalizedDescriptionKey :
                NSLocalizedString("fail",
                                  value: value,
                                  comment: "")
        ]
        let error = NSError(domain: ApiManager.domain, code: code, userInfo: userInfo)
        self.view.displayErrorMessage(errorMessage: error.localizedDescription)
    }
    
    // get data from userDefaults
    func getSavedData() {
        guard let weaher = UserDefaultsManager.shared.getWeaher() else { return }
        guard let colorStringCase = UserDefaultsManager.shared.getBackgroundColor() else { return }
        let bacgroundColorCase = BackgroundColorCase(value: colorStringCase)
        view.setBackroundColor(bacgroundColorCase: bacgroundColorCase)
        view.displayWeather(mainScreenWeatherModel: weaher)
    }
    
   // if internet swiched off and weaher wasn't received
   // this timer will call getWeather function every 5 seconds and try to get weather data
    private func createTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 5.0,
                                         target: self,
                                         selector: #selector(getWeather),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    // convert Weather to MainScreenWeatherModel
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
        var sunriseTime: Double!
        var sunsetTime: Double!
        
        let currentTime = weather.hourly.data[0].time
        
        if weather.daily.data[0].sunriseTime > currentTime {
            sunriseTime = weather.daily.data[0].sunriseTime
        } else {
            sunriseTime = weather.daily.data[1].sunriseTime
        }
        if weather.daily.data[0].sunsetTime > currentTime {
            sunsetTime = weather.daily.data[0].sunsetTime
        } else {
            sunsetTime = weather.daily.data[1].sunsetTime
        }
        
        for weather in weather.hourly.data {
            let mainScreenHourlyWeatherModel =
                MainScreenHourlyWeatherModel(stringTime: weather.getStringTime(),
                                             unixTime: weather.time,
                                             icon: weather.icon,
                                             degrees: fahrenheitToCelsius(weather.temperature)+"°",
                                             precipProbability: String(Int(weather.precipProbability*100))+"%")
            mainScreenHourlyWeather.append(mainScreenHourlyWeatherModel)
        }
        let sunriseTimeWeather = MainScreenHourlyWeatherModel(stringTime: formatSunsetAndSunriseTime(sunriseTime),
                                                              unixTime: sunriseTime,
                                                              icon: "sunrise",
                                                              degrees: "Sunrise",
                                                              precipProbability: "")
        let sunsetTimeWeather = MainScreenHourlyWeatherModel(stringTime: formatSunsetAndSunriseTime(sunsetTime),
                                                             unixTime: sunsetTime,
                                                             icon: "sunset",
                                                             degrees: "Sunset",
                                                             precipProbability: "")
        mainScreenHourlyWeather.append(sunriseTimeWeather)
        mainScreenHourlyWeather.append(sunsetTimeWeather)
        mainScreenHourlyWeather.sort { (one, two) -> Bool in
            return one.unixTime < two.unixTime
        }
        mainScreenHourlyWeather[0].stringTime = "Now"
        
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

//MARK: - CLLocationManagerDelegate
extension MainScreenPresenter: CLLocationManagerDelegate {
    //trying to get user location and city
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global().async { [unowned self] in
            if let location = locations.first {
                let url = self.urlManager.getURL(latitude: String(location.coordinate.latitude),
                                                 longitude: String(location.coordinate.longitude))!
                self.apiManager = ApiManager(url: url)
                location.fetchCity { [unowned self] (city, error)  in
                    if let city = city {
                        self.city = city
                    } else {
                        self.city = "Not Found"
                    }
                    if !self.isgetWeatherFinished {
                        self.getWeather()
                    }
                    self.isgetWeatherFinished = true
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        createErrorMessage(value: "Failed to determine location, please go to Settings and turn on the permissions", code: 6)
    }
    
}
