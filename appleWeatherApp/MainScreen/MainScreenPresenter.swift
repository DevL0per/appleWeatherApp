//
//  MainScreenPresenter.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import Foundation

protocol MainScreenPresenterProtocol {
    func getWeather()
}

class MainScreenPresenter: MainScreenPresenterProtocol {
    
    let apiManager: ApiManager!
    let urlManager = URLManager()
    var view: MainScreenView!
    
    init() {
        let url = urlManager.getURL(latitude: "37.8267", longitude: "-122.4233")!
        apiManager = ApiManager(url: url)
    }
    
    func getWeather() {
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
    }
    
    private func weatherToMainScreenWeatherModel(weather: Weather) -> MainScreenWeatherModel {
        let mainScreenCurrentWeatherModel =
            MainScreenCurrentWeatherModel(temperature: fahrenheitToCelsius(weather.currently.temperature),
                                          day: String("monday"),
                                          maxTemperature: fahrenheitToCelsius(weather.daily.data[0].temperatureHigh),
                                          minTemperature: fahrenheitToCelsius(weather.daily.data[0].temperatureLow),
                                          sammery: String(weather.currently.summary))
        // hourly weatherModel
        var mainScreenHourlyWeather: [MainScreenHourlyWeatherModel] = []
        let sunriseTime = weather.daily.data[1].sunriseTime
        let sunsetTime = weather.daily.data[0].sunsetTime
        
        
//        formatSunsetAndSunriseTime
        for weather in weather.hourly.data {
            let mainScreenHourlyWeatherModel =
                MainScreenHourlyWeatherModel(stringTime: weather.getStringTime(),
                                             unixTime: weather.time,
                                             icon: weather.icon,
                                             degrees: fahrenheitToCelsius(weather.temperature))
            mainScreenHourlyWeather.append(mainScreenHourlyWeatherModel)
        }
        let sunriseTimeWeather = MainScreenHourlyWeatherModel(stringTime: formatSunsetAndSunriseTime(sunriseTime),
                                                              unixTime: sunriseTime,
                                                              icon: "",
                                                              degrees: "Sunrise")
        let sunsetTimeWeather = MainScreenHourlyWeatherModel(stringTime: formatSunsetAndSunriseTime(sunsetTime),
                                                             unixTime: sunsetTime,
                                                             icon: "",
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
                                    chanceOfRain: String(weather.currently.precipProbability)+"%",
                                    humidity: String(weather.currently.humidity),
                                    wind: String(weather.currently.windSpeed),
                                    feelsLike: String(weather.currently.apparentTemperature),
                                    precipitation: String(weather.currently.precipIntensity),
                                    pressure: String(weather.currently.pressure),
                                    visiblity: String(weather.currently.visibility),
                                    uvIndex: String(weather.currently.uvIndex))
        let mainScreenWeatherModel = MainScreenWeatherModel(mainScreenCurrentWeatherModel: mainScreenCurrentWeatherModel,
                                                            mainContentWeatherModel: mainContentWeatherModel, mainScreenHourlyWeatherModel: mainScreenHourlyWeather, mainScreenDailyWeatherModel: mainScreenDailyWeather)
        return mainScreenWeatherModel
    }
    
    private func fahrenheitToCelsius(_ temperature: Double) -> String {
        return String(Int((temperature-32)/(9/5))) + "°"
    }

    private func formatSunsetAndSunriseTime(_ unixDate: Double) -> String {
        let date = Date(timeIntervalSince1970: unixDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}
