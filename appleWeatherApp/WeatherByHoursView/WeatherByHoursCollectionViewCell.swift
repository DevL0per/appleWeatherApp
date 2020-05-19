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
        label.text = "-"
        return label
    }()
    
    private let temperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 19)
        return label
    }()
    
    private let chanceOfPrecipitationLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.textColor = #colorLiteral(red: 0.3952505589, green: 0.7498927712, blue: 0.9492647052, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let weaherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chanceOfPrecipitationLabel.isHidden = true
        weaherIconImageView.image = nil
        timeLabel.text = ""
        temperatureLabel.text = ""
    }

    func setupElements(data: MainScreenHourlyWeatherModel?) {
        guard let data = data else { return }
        timeLabel.text = data.stringTime
        temperatureLabel.text = data.degrees
        weaherIconImageView.image = data.getIconImage()
        if data.icon == "rain" || data.icon == "snow" {
            chanceOfPrecipitationLabel.isHidden = false
            chanceOfPrecipitationLabel.text = data.precipProbability
        }
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
        
        addSubview(chanceOfPrecipitationLabel)
        chanceOfPrecipitationLabel.bottomAnchor.constraint(equalTo: weaherIconImageView.topAnchor).isActive = true
        chanceOfPrecipitationLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
