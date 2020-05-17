//
//  MainScreenDataModel.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 16.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

struct MainScreenWeatherModel {
    let mainScreenCurrentWeatherModel: MainScreenCurrentWeatherModel
    let mainContentWeatherModel: MainContentWeatherModel
    let mainScreenHourlyWeatherModel: [MainScreenHourlyWeatherModel]
    let mainScreenDailyWeatherModel: [MainScreenDailyWeatherModel]
}

struct MainScreenCurrentWeatherModel {
    let temperature: String
    let day: String
    let maxTemperature: String
    let minTemperature: String
    let sammery: String
    
    static func getCurrentDay() -> String {
        let index = Calendar.current.component(.weekday, from: Date())
        return Calendar.current.weekdaySymbols[index - 1]
    }
}

struct MainScreenHourlyWeatherModel {
    let stringTime: String
    let unixTime: Double
    let icon: String
    let degrees: String
    
    func getIconImage() -> UIImage {
        let iconCase = WeatherIconCases(value: icon)
        return iconCase.iconImage
    }
}


struct MainScreenDailyWeatherModel {
    let day: String
    let icon: String
    let maxTemperature: String
    let minTemperature: String
    
    func getIconImage() -> UIImage {
        let iconCase = WeatherIconCases(value: icon)
        return iconCase.iconImage
    }
}

struct MainContentWeatherModel {
    let message: String
    let sunrise: String
    let sunset: String
    let chanceOfRain: String
    let humidity: String
    let wind: String
    let feelsLike: String
    let precipitation: String
    let pressure: String
    let visiblity: String
    let uvIndex: String
}
