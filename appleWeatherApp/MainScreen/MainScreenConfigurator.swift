//
//  MainScreenConfigurator.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 17.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import Foundation

protocol MainScreenConfiguratorProtocol: class {
    func configure(view: MainScreenViewController)
}

class MainScreenConfigurator: MainScreenConfiguratorProtocol {
    func configure(view: MainScreenViewController) {
        let presenter = MainScreenPresenter()
        presenter.view = view
        view.presenter = presenter
    }
}
