//
//  Weather.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import Foundation
//
//enum Days {
//    case "Sunday"
//    "Monday",
//    "Tuesday",
//    "Wednesday",
//    "Thursday",
//    "Friday",
//    "Saturday"
//}

struct Weather: Decodable {
    let currently: CurrentWeater
    let daily: DailyWeatherData
    let hourly: HourlyWeatherData
}

struct DailyWeatherData: Decodable {
    let data: [DailyWeather]
}

struct HourlyWeatherData: Decodable {
    let data: [HourlyWeather]
}

struct CurrentWeater: Decodable {
    let temperature: Double
    let apparentTemperature: Double
    let icon: String
    let precipProbability: Double
    let humidity: Double
    let windSpeed: Double
    let pressure: Double
    let precipIntensity: Int
    let visibility: Double
    let uvIndex: Int
    let summary: String
}

struct DailyWeather: Decodable {
    let time: Double
    let icon: String
    let temperatureHigh: Double
    let temperatureLow: Double
    let sunriseTime: Double
    let sunsetTime: Double
    let summary: String
    
    func getDay() -> String {
        let date = Date(timeIntervalSince1970: time)
        let index = Calendar.current.component(.weekday, from: date)
        return Calendar.current.weekdaySymbols[index - 1]
    }
}

struct HourlyWeather: Decodable {
    let time: Double
    let icon: String
    let temperature: Double
    
    func getStringTime() -> String {
       let date = Date(timeIntervalSince1970: time)
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "HH"
       dateFormatter.timeZone = .current
       return dateFormatter.string(from: date)
    }
}
