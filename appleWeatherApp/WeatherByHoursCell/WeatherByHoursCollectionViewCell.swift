//
//  WeatherByHoursCollectionViewCell.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let spacingBetweenElements: CGFloat = 15
}

class WeatherByHoursCollectionViewCell: UICollectionViewCell {
    
    private let timeLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "23"
        return label
    }()
    
    private let temperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "5°"
        label.font = UIFont.systemFont(ofSize: 19)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutElements()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupElements(data: MainScreenHourlyWeatherModel?) {
        guard let data = data else { return }
        timeLabel.text = data.stringTime
        temperatureLabel.text = data.degrees
    }
    
    private func layoutElements() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = Constants.spacingBetweenElements
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(weaherIconImageView)
        stackView.addArrangedSubview(temperatureLabel)
        
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
}
