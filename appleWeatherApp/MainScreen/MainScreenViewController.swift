//
//  ViewController.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let offsetHeight: CGFloat = 150
    static let tableViewCellHeight: CGFloat = 120
}

class MainScreenViewController: UIViewController {
    
    private var offsetHeight = Constants.offsetHeight
    fileprivate var isTableViewEnabled = false
    fileprivate var isScrollEnable = false
    private var topContentView: ContentView = {
        let view = ContentView()
        return view
    }()
    
    // Labels
    private let cityLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "Minsk"
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    private let shortInfoAboutWeatherLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "Mostly Cloudy"
        return label
    }()
    private let temperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "4°"
        label.font = UIFont.systemFont(ofSize: 90, weight: .thin)
        return label
    }()
    private let todayLabel: UILabel = {
        let label = WeatherLabel()
        label.text = "Tuesday"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    private let todayStaticLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "TODAY"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset = UIEdgeInsets(top: Constants.offsetHeight,
                                              left: 0, bottom: 0, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setContentOffset(CGPoint(x: 0, y: -Constants.offsetHeight), animated: false)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherByHoursCell.self, forCellReuseIdentifier: "weatherByHoursCell")
        tableView.register(MainTableViewContentCell.self, forCellReuseIdentifier: "mainTableViewContentCell")
        tableView.backgroundColor = .clear

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.239831388, green: 0.5518291593, blue: 0.7405184507, alpha: 1)
        layoutTopContentView()
        layoutTableView()
        layoutTopLabels()
    }
    
    private func layoutTopContentView() {
        view.addSubview(topContentView)
        topContentView.backgroundColor = .clear
        topContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        topContentView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        topContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        //labels setup
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(cityLabel)
        stackView.addArrangedSubview(shortInfoAboutWeatherLabel)
        
        topContentView.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: topContentView.centerXAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: topContentView.bottomAnchor).isActive = true
    }

    private func layoutTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: topContentView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        isTableViewEnabled = true
    }
    
    private func layoutTopLabels() {
        tableView.addSubview(temperatureLabel)
        temperatureLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: (-Constants.offsetHeight))
            .isActive = true
        temperatureLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(todayLabel)
        stackView.addArrangedSubview(todayStaticLabel)
    
        tableView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -15).isActive = true
    }
    
}


extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.row == 0 {
            cell = WeatherByHoursCell()
        } else {
            cell = MainTableViewContentCell()
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return Constants.tableViewCellHeight
        } else {
            return (6*40)+(9*40)-100
        }
    }
    
}

extension MainScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTableViewEnabled {
            let inset = -scrollView.contentOffset.y
            var alpha = 1 * inset / Constants.offsetHeight
            if alpha <= 0 {
                tableView.isScrollEnabled = false
            }
            if alpha < 1 {
                alpha-=0.35
            }
            todayStaticLabel.alpha = alpha
            todayLabel.alpha = alpha
            temperatureLabel.alpha = alpha
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (-scrollView.contentOffset.y) < Constants.offsetHeight/2 {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.todayStaticLabel.alpha = 0
                self.todayLabel.alpha = 0
                self.temperatureLabel.alpha = 0
                scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
        } else {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.todayStaticLabel.alpha = 1
                self.todayLabel.alpha = 1
                self.temperatureLabel.alpha = 1
                scrollView.contentOffset = CGPoint(x: 0, y: -Constants.offsetHeight)
            }
        }
    }
}
