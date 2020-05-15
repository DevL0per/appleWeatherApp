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

class MainTableViewContentCell: UITableViewCell {
    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WeatherForAWeekTableViewCell.self, forCellReuseIdentifier: "weatherForAWeekCell")
        tableView.register(WeatherDataCell.self, forCellReuseIdentifier: "weatherDataCell")
        tableView.register(WeatherForAWeekTableViewCell.self, forCellReuseIdentifier: "weatherForAWeekTableViewCell")
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        //tableView.isScrollEnabled = false
        return tableView
    }()
    
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
        case 1:
            cell = ShortInfoCell()
        case 2...6:
             cell = WeatherDataCell()
        default:
            cell = UITableViewCell()
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 9*40
        case 1:
            return UITableView.automaticDimension
        default:
            return 45
        }
    }
}


