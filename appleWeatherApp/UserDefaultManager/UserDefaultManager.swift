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
    
    func saveProgress(weaherViewModel: MainScreenWeatherModel) {
        defaults.set(try? PropertyListEncoder().encode(weaherViewModel), forKey: id)
    }
    
    func getProgress() -> MainScreenWeatherModel? {
        if let data = defaults.value(forKey: id) as? Data {
            let weaher = try? PropertyListDecoder().decode(MainScreenWeatherModel.self, from: data)
            return weaher
        } else {
            return nil
        }
    }
}
