//
//  LabelWithPaddings.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 13.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

@IBDesignable class LabelWithPaddings: WeatherLabel {

    @IBInspectable var topInset: CGFloat = 10
    @IBInspectable var bottomInset: CGFloat = 10
    @IBInspectable var leftInset: CGFloat = 10
    @IBInspectable var rightInset: CGFloat = 10

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
