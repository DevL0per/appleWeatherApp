//
//  WeatherForAWeekCell.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 13.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

class WeatherForAWeekCell: UITableViewCell {
   
    private let dayLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Friday"
        return label
    }()
    
    private let weaherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sun")
        return imageView
    }()
    
    private let maxTemperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "12"
        return label
    }()
    
    private let minTemperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "1"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupElements(day: String, maxTemperature: String, minTemperature: String) {
        dayLabel.text = day
        maxTemperatureLabel.text = maxTemperature
        minTemperatureLabel.text = minTemperature
    }
    
    private func layoutElements() {
        addSubview(dayLabel)
        dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(weaherIconImageView)
        weaherIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        weaherIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(maxTemperatureLabel)
        stackView.addArrangedSubview(minTemperatureLabel)
        
        addSubview(stackView)
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
