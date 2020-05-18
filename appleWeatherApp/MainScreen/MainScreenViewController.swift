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
    static let bottomContentViewHeight: CGFloat = 30
    static let defaultScreenWidth: CGFloat = 375
}

enum BackgroundColorCase: String {
    case night = "night"
    case day = "day"
    case precipitation = "precipitation"
    
    init(value: String) {
        switch value {
        case "night":
            self = .night
        case "day":
            self = .day
        case "precipitation":
            self = .precipitation
        default:
            self = .day
        }
    }
    
    func getColor() -> UIColor {
        switch self {
        case .day:
            return #colorLiteral(red: 0.239831388, green: 0.5518291593, blue: 0.7405184507, alpha: 1)
        case .night:
            return #colorLiteral(red: 0.05488184839, green: 0.07055146247, blue: 0.1697204709, alpha: 1)
        case .precipitation:
            return #colorLiteral(red: 0.45586133, green: 0.5314458013, blue: 0.5995544791, alpha: 1)
        }
    }
}

protocol MainScreenView {
    func displayWeather(mainScreenWeatherModel: MainScreenWeatherModel)
    func displayErrorMessage(errorMessage: String)
    func setBackroundColor(bacgroundColorCase: BackgroundColorCase)
}

class MainScreenViewController: UIViewController, MainScreenView {
    
    var presenter: MainScreenPresenterProtocol!
    private let configurator: MainScreenConfiguratorProtocol = MainScreenConfigurator()
    
    private var weatherByHoursView = WeatherByHoursView()
    private lazy var backgroundView: ContentView = {
        let view = ContentView()
        view.backgroundColor = self.view.backgroundColor
        return view
    }()
    
    private let bottomView = ContentView()
    private let bottomSeparatorView = SeparatorView()
    
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
        var fontSize: CGFloat!
        if UIScreen.main.bounds.width > Constants.defaultScreenWidth {
            fontSize = 100
        } else {
            fontSize = 90
        }
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
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
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style:UIStatusBarStyle = .lightContent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.239831388, green: 0.5518291593, blue: 0.7405184507, alpha: 1)
        layoutTopContentView()
        bottomViewLayout()
        layoutTableView()
        layoutTopLabels()
        configurator.configure(view: self)
        setTodayLabelText()
        presenter.getSavedData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.contentOffset = CGPoint(x: 0, y: -(Constants.offsetHeight+Constants.tempretureSectionHeight))
    }
    
    func displayWeather(mainScreenWeatherModel: MainScreenWeatherModel) {
        // setup labels
        cityLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.city
        temperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.temperature
        todayLabel.text = MainScreenCurrentWeatherModel.getCurrentDay()
        shortInfoAboutWeatherLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.sammery
        maxTemperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.maxTemperature
        minTemperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.minTemperature
        // setup viewModel and reload tableView
        viewModel = mainScreenWeatherModel
        weatherByHoursView.viewModel = mainScreenWeatherModel.mainScreenHourlyWeatherModel
        createDataArrayForMainSection()
        tableView.reloadData()
    }
    
    // if there is some mistake display it in alert
    func displayErrorMessage(errorMessage: String) {
        let alert = AlertManager.shared.createAlert(title: "Error",
                                                    subtitle: errorMessage,
                                                    actionTitle: "Ok")
        present(alert, animated: true, completion: nil)
    }
    
    func setBackroundColor(bacgroundColorCase: BackgroundColorCase) {
        let color = bacgroundColorCase.getColor()
        if bacgroundColorCase == .night {
           self.style = .lightContent
        } else {
            self.style = .darkContent
        }
        view.backgroundColor = color
        weatherByHoursView.backgroundColor = color
        backgroundView.backgroundColor = color
        bottomView.backgroundColor = color
    }
    
    private func setTodayLabelText() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            todayStaticLabel.text = "TODAY"
        default:
            todayStaticLabel.text = "TONIGHT"
        }
    }
    
    //MARK: - Layout elements
    
    private func layoutTopContentView() {
        view.addSubview(topContentView)
        topContentView.backgroundColor = .clear
        topContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        topContentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/5.5).isActive = true
        topContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // stackView for labels setup
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
    
    // weatherByHoursView topAnchor (if the view reachs the top, Anchor will be changed)
    var topAnchor: NSLayoutConstraint?
    var isTopAnchorConnectedToTableView = true
    private func layoutTableView() {
        // layout tableView
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: topContentView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomSeparatorView.topAnchor).isActive = true
        
        // layout tableView weatherByHoursView
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
        
        // layout minTemperatureLabel and maxTemperatureLabel
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
        
        // layout todayLabel and todayStaticLabel
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(todayLabel)
        stackView.addArrangedSubview(todayStaticLabel)
        
        tableView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: weatherByHoursView.topAnchor, constant: -15).isActive = true
        todayStaticLabel.centerYAnchor.constraint(equalTo: todayLabel.centerYAnchor).isActive = true
    }
    
    private func bottomViewLayout() {
        let safeBottomAnchor = view.layoutMarginsGuide.bottomAnchor
        view.addSubview(bottomView)
        bottomView.backgroundColor = view.backgroundColor
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.heightAnchor.constraint(equalToConstant: Constants.bottomContentViewHeight).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: safeBottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(bottomSeparatorView)
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        bottomSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    // create an array for weatherDataCell
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
                leftText = viewModel.mainContentWeatherModel.sunrise
                rightText = viewModel.mainContentWeatherModel.sunset
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
        case 2...5:
            cell = WeatherDataCell()
            if let mainSectionData = mainSectionData {
                (cell as! WeatherDataCell).setupElements(mainSectionData: mainSectionData[indexPath.row-2])
            }
        case 6:
            // WeatherDataCell without bottomSeparator
            cell = WeatherDataCell()
            if let mainSectionData = mainSectionData {
                (cell as! WeatherDataCell).setupElements(mainSectionData: mainSectionData[indexPath.row-2],
                                                         hideBottomSeparator: true)
            }
        default:
            cell = UITableViewCell()
        }
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = false
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
    
    // culculate alpha depending on the scrollView offset
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = -scrollView.contentOffset.y
        var alpha = 1 * (offset-Constants.tempretureSectionHeight) / (Constants.offsetHeight)
        var temperatureAplha = alpha
        // if scrollView has riched the top change topAnchor
        if offset <= Constants.tempretureSectionHeight {
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
    
    // if user stops scrolling scrollView and doesn't reach the top - scroll to the top
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
    
    // attach object to topView
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
    
    // attach object to tableView back
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

