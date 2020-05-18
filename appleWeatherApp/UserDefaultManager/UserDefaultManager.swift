//
//  UserDefaultManager.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 18.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    private let id = "weaher"
    private let backgroundColorId = "backroundCase"
    
    func saveWeaher(weaherViewModel: MainScreenWeatherModel) {
        defaults.set(try? PropertyListEncoder().encode(weaherViewModel), forKey: id)
    }
    
    func getWeaher() -> MainScreenWeatherModel? {
        if let data = defaults.value(forKey: id) as? Data {
            return try? PropertyListDecoder().decode(MainScreenWeatherModel.self, from: data)
        } else {
            return nil
        }
    }
    
    func saveBackroundColor(backgroundColorCase: String) {
        defaults.set(backgroundColorCase, forKey: backgroundColorId)
    }
    
    func getBackgroundColor() -> String? {
        if let backgroundColorCase = defaults.value(forKey: backgroundColorId) as? String {
            return backgroundColorCase
        } else {
            return nil
        }
    }
}
