//
//  WeatherForAWeekCell.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

//fileprivate enum MainContentCells: Int {
//    case weatherForAWeekCell = 0
//    case weatherDataCell = 1
//    case weatherForAWeekTableViewCell = 2...6
//}

struct MainSectionData {
    let leftTitleText: String
    let rightTitleText: String
    let leftText: String
    let rightText: String
}

protocol MainTableViewContentCellDelegate {
    func changeTableViewScrollState()
}

class MainTableViewContentCell: UITableViewCell {
    fileprivate lazy var weatherTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WeatherForAWeekTableViewCell.self, forCellReuseIdentifier: "weatherForAWeekCell")
        tableView.register(WeatherDataCell.self, forCellReuseIdentifier: "weatherDataCell")
        tableView.register(WeatherForAWeekTableViewCell.self, forCellReuseIdentifier: "weatherForAWeekTableViewCell")
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 45, right: 0)
        return tableView
    }()
     
    var viewModel: MainScreenWeatherModel? {
        didSet {
            createDataArrayForMainSection()
            weatherTableView.reloadData()
        }
    }
    var delegate: MainTableViewContentCellDelegate!
    private var mainSectionData: [MainSectionData]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutElements() {
        addSubview(weatherTableView)
        weatherTableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        weatherTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        weatherTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        weatherTableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func createDataArrayForMainSection() {
        guard let viewModel = viewModel else { return }
        mainSectionData = []
        for number in 0...4 {
            var leftTitleText = ""
            var rightTitleText = ""
            var leftText = ""
            var rightText = ""
            switch number {
            case 0:
                leftTitleText = "SUNRISE"
                rightTitleText = "SUNSET"
                leftText = viewModel.mainContentWeatherModel.sunset
                rightText = viewModel.mainContentWeatherModel.sunrise
            case 1:
                leftTitleText = "CHANCE OF RAIN"
                rightTitleText = "HUMIDITY"
                leftText = viewModel.mainContentWeatherModel.chanceOfRain
                rightText = viewModel.mainContentWeatherModel.humidity
            case 2:
                leftTitleText = "WIND"
                rightTitleText = "FEELS LIKE"
                leftText = viewModel.mainContentWeatherModel.wind
                rightText = viewModel.mainContentWeatherModel.feelsLike
            case 3:
                leftTitleText = "PRECIPITATION"
                rightTitleText = "PRESSURE"
                leftText = viewModel.mainContentWeatherModel.precipitation
                rightText = viewModel.mainContentWeatherModel.pressure
            case 4:
                leftTitleText = "VISIBILITY"
                rightTitleText = "UV INDEX"
                leftText = viewModel.mainContentWeatherModel.visiblity
                rightText = viewModel.mainContentWeatherModel.uvIndex
            default:
                break
            }
            let data = MainSectionData(leftTitleText: leftTitleText,
                                                  rightTitleText: rightTitleText,
                                                  leftText: leftText,
                                                  rightText: rightText)
            mainSectionData?.append(data)
        }
    }
}

extension MainTableViewContentCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.row {
        case 0:
            cell = WeatherForAWeekTableViewCell()
            (cell as! WeatherForAWeekTableViewCell).viewModel = viewModel?.mainScreenDailyWeatherModel
        case 1:
            cell = ShortInfoCell()
            (cell as! ShortInfoCell).setupElements(text: viewModel?.mainContentWeatherModel.message ?? "")
        case 2...6:
            cell = WeatherDataCell()
            if let mainSectionData = mainSectionData {
                (cell as! WeatherDataCell).setupElements(mainSectionData: mainSectionData[indexPath.row-2])
            }
        default:
            cell = UITableViewCell()
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 7*40
        case 1:
            return UITableView.automaticDimension
        default:
            return 55
        }
    }
}


extension MainTableViewContentCell: MainScreenViewControllerDelegate {
    
    func scrollViewShouldStartScrolling(scroll: UIScrollView) {
//        self.weatherTableView.isScrollEnabled = true
    }
    
    func changeMainTableViewScrollState(isEnable: Bool) {
        weatherTableView.isScrollEnabled = isEnable
    }
}

extension MainTableViewContentCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
            scrollView.isScrollEnabled = false
            delegate.changeTableViewScrollState()
        }
    }
}
