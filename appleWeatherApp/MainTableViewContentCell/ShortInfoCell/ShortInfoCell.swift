//
//  ShortInfoCell.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 13.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

class ShortInfoCell: UITableViewCell {
    
    let infoLabel: LabelWithPaddings = {
        let label = LabelWithPaddings()
        label.numberOfLines = 0
        label.text = "fdfdsfsudhfusdhugihduighdfuhgidhfugudhfughdufiguihdfuighdfdhgiufdhg"
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
    
    private func layoutElements() {
        addSubview(bottomSeparatorView)
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(infoLabel)
        infoLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: bottomSeparatorView.topAnchor).isActive = true
        
    }
}
