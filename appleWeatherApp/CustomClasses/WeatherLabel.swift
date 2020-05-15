//
//  WeatherLabel.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

class WeatherLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
