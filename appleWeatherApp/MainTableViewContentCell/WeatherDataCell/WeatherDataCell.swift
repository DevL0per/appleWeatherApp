//
//  WeatherDataCell.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 13.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

class WeatherDataCell: UITableViewCell {
    
    private let leftTopLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.textColor = .lightGray
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    private let leftBottomLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    private let rightTopLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    private let rightBottomLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    let bottomSeparatorView = SeparatorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupElements(mainSectionData: MainSectionData, hideBottomSeparator: Bool = false) {
        leftTopLabel.text = mainSectionData.leftTitleText
        rightTopLabel.text = mainSectionData.rightTitleText
        leftBottomLabel.text = mainSectionData.leftText
        rightBottomLabel.text = mainSectionData.rightText
        bottomSeparatorView.isHidden = hideBottomSeparator
    }
    
    private func layoutElements() {
        addSubview(bottomSeparatorView)
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.alignment = .leading
        leftStackView.distribution = .equalSpacing
        leftStackView.spacing = 0
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.addArrangedSubview(leftTopLabel)
        leftStackView.addArrangedSubview(leftBottomLabel)
        
        addSubview(leftStackView)
        
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.alignment = .leading
        rightStackView.distribution = .equalSpacing
        rightStackView.spacing = 0
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.addArrangedSubview(rightTopLabel)
        rightStackView.addArrangedSubview(rightBottomLabel)
        
        addSubview(rightStackView)
        
        leftStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        leftStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        rightStackView.leadingAnchor.constraint(equalTo: centerXAnchor).isActive = true
        rightStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
