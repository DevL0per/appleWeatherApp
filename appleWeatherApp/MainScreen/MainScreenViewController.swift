//
//  ViewController.swift
//  appleWeatherApp
//
//  Created by Роман Важник on 12.05.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let tempretureSectionHeight: CGFloat = 120
    static let offsetHeight: CGFloat = UIScreen.main.bounds.height/5
    static let numberOfRowsInSection = 7
    static let heightForFirstRow: CGFloat = 40
    static let heightForMainContentCells: CGFloat = 55
}

struct MainSectionData {
    let leftTitleText: String
    let rightTitleText: String
    let leftText: String
    let rightText: String
}

protocol MainScreenViewControllerDelegate {
    func changeMainTableViewScrollState(isEnable: Bool)
    func scrollViewShouldStartScrolling(scroll: UIScrollView)
}

protocol MainScreenView {
    func displayWeather(mainScreenWeatherModel: MainScreenWeatherModel)
    func displayErrorMessage(errorMessage: String)
}

class MainScreenViewController: UIViewController, MainScreenView {
    
    var delegate: MainScreenViewControllerDelegate!
    var presenter: MainScreenPresenterProtocol!
    
    private let configurator: MainScreenConfiguratorProtocol = MainScreenConfigurator()
    
    private var weatherByHoursView = WeatherByHoursView()
    private lazy var backgroundView: ContentView = {
        let view = ContentView()
        view.backgroundColor = self.view.backgroundColor
        return view
    }()
    
    private var topContentView: ContentView = {
        let view = ContentView()
        return view
    }()
    // Labels
    private let cityLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "loading"
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    private let shortInfoAboutWeatherLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "-"
        return label
    }()
    private let temperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 90, weight: .thin)
        return label
    }()
    private let todayLabel: UILabel = {
        let label = WeatherLabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    private let todayStaticLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "TODAY"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    private let maxTemperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    private let minTemperatureLabel: WeatherLabel = {
        let label = WeatherLabel()
        label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.65)
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private var viewModel: MainScreenWeatherModel?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WeatherForAWeekTableViewCell.self, forCellReuseIdentifier: "weatherForAWeekCell")
        tableView.register(WeatherDataCell.self, forCellReuseIdentifier: "weatherDataCell")
        tableView.register(WeatherForAWeekTableViewCell.self, forCellReuseIdentifier: "weatherForAWeekTableViewCell")
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: Constants.offsetHeight+Constants.tempretureSectionHeight,
                                              left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.239831388, green: 0.5518291593, blue: 0.7405184507, alpha: 1)
        layoutTopContentView()
        layoutTableView()
        layoutTopLabels()
        configurator.configure(view: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.contentOffset = CGPoint(x: 0, y: -(Constants.offsetHeight+Constants.tempretureSectionHeight))
    }
    
    func displayWeather(mainScreenWeatherModel: MainScreenWeatherModel) {
        cityLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.city
        temperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.temperature
        todayLabel.text = MainScreenCurrentWeatherModel.getCurrentDay()
        shortInfoAboutWeatherLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.sammery
        maxTemperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.maxTemperature
        minTemperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.minTemperature
        viewModel = mainScreenWeatherModel
        weatherByHoursView.viewModel = mainScreenWeatherModel.mainScreenHourlyWeatherModel
        createDataArrayForMainSection()
        tableView.reloadData()
    }
    
    func displayErrorMessage(errorMessage: String) {
        
    }
    
    //MARK: - Layout elements
    
    private func layoutTopContentView() {
        view.addSubview(topContentView)
        topContentView.backgroundColor = .clear
        topContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        topContentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/5.5).isActive = true
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
        stackView.bottomAnchor.constraint(equalTo: topContentView.bottomAnchor, constant: -20).isActive = true
    }
    
    var topAnchor: NSLayoutConstraint?
    var isTopAnchorConnectedToTableView = true
    private func layoutTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: topContentView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.addSubview(backgroundView)
        tableView.addSubview(weatherByHoursView)
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: weatherByHoursView.bottomAnchor).isActive = true
        
        weatherByHoursView.translatesAutoresizingMaskIntoConstraints = false
        weatherByHoursView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        weatherByHoursView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        weatherByHoursView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topAnchor = weatherByHoursView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        weatherByHoursView.backgroundColor = #colorLiteral(red: 0.239831388, green: 0.5518291593, blue: 0.7405184507, alpha: 1)
        topAnchor!.isActive = true
        
    }
    
    private func layoutTopLabels() {
        view.addSubview(temperatureLabel)
        temperatureLabel.topAnchor.constraint(equalTo: topContentView.bottomAnchor)
            .isActive = true
        temperatureLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        
        let minMaxLabelsStackView = UIStackView()
        minMaxLabelsStackView.axis = .horizontal
        minMaxLabelsStackView.alignment = .center
        minMaxLabelsStackView.distribution = .equalSpacing
        minMaxLabelsStackView.spacing = 15
        minMaxLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        minMaxLabelsStackView.addArrangedSubview(maxTemperatureLabel)
        minMaxLabelsStackView.addArrangedSubview(minTemperatureLabel)
        
        tableView.addSubview(minMaxLabelsStackView)
        minMaxLabelsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        minMaxLabelsStackView.bottomAnchor.constraint(equalTo: weatherByHoursView.topAnchor, constant: -15).isActive = true
        
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
        stackView.bottomAnchor.constraint(equalTo: weatherByHoursView.topAnchor, constant: -15).isActive = true
    }
    
    private func bottomViewLayout() {
    }
    
    private var mainSectionData: [MainSectionData]?
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


//MARK: - TableViewDelegate
extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfRowsInSection
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
            return CGFloat(viewModel?.mainScreenDailyWeatherModel.count ?? 7)*Constants.heightForFirstRow
        case 1:
            return UITableView.automaticDimension
        default:
            return Constants.heightForMainContentCells
        }
    }
    
}

//MARK: - ScrollViewDelegate
extension MainScreenViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let inset = -scrollView.contentOffset.y
        var alpha = 1 * (inset-Constants.tempretureSectionHeight) / (Constants.offsetHeight)
        var temperatureAplha = alpha
        if inset <= Constants.tempretureSectionHeight {
            stopHourlyWeatherSection()
        } else {
            attachHourlyWeathernToTableView()
        }
        if alpha < 1 {
            temperatureAplha-=0.55
            alpha-=0.60
        }
        minTemperatureLabel.alpha = alpha
        maxTemperatureLabel.alpha = alpha
        todayStaticLabel.alpha = alpha
        todayLabel.alpha = alpha
        temperatureLabel.alpha = temperatureAplha
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = -scrollView.contentOffset.y
        if (offset > Constants.tempretureSectionHeight
            && offset < (Constants.offsetHeight+Constants.tempretureSectionHeight))
            && isTopAnchorConnectedToTableView {
            UIView.animate(withDuration: 0.2, animations: { [unowned self] in
                self.todayStaticLabel.alpha = 0
                self.todayLabel.alpha = 0
                self.temperatureLabel.alpha = 0
                scrollView.contentOffset = CGPoint(x: 0, y: -Constants.tempretureSectionHeight)
            }) { [unowned self] (isComlited) in
                if isComlited {
                    self.isTopAnchorConnectedToTableView = false
                }
            }
        }
    }
    
    fileprivate func stopHourlyWeatherSection() {
        if isTopAnchorConnectedToTableView {
            if let topAnchor = topAnchor {
                topAnchor.isActive = false
            }
            topAnchor = weatherByHoursView.topAnchor.constraint(equalTo: topContentView.bottomAnchor)
            topAnchor?.isActive = true
            isTopAnchorConnectedToTableView = false
        }
    }
    
    fileprivate func attachHourlyWeathernToTableView() {
        if !isTopAnchorConnectedToTableView {
            if let topAnchor = topAnchor {
                topAnchor.isActive = false
            }
            topAnchor = weatherByHoursView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
            topAnchor?.isActive = true
            isTopAnchorConnectedToTableView = true
        }
    }
}

