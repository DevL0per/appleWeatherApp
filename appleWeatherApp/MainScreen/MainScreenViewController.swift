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

protocol MainScreenViewControllerDelegate {
    func changeMainTableViewScrollState(isEnable: Bool)
    func scrollViewShouldStartScrolling(scroll: UIScrollView)
}

protocol MainScreenView {
    func displayWeather(mainScreenWeatherModel: MainScreenWeatherModel)
    func displayErrorMessage(errorMessage: String)
}

var secondCell: UITableViewCell!

class MainScreenViewController: UIViewController, MainScreenView {

    var delegate: MainScreenViewControllerDelegate!
    var presenter: MainScreenPresenterProtocol!
    private let configurator: MainScreenConfiguratorProtocol = MainScreenConfigurator()
    
    fileprivate var previousEnableStateEnable = false
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
    
    private var viewModel: MainScreenWeatherModel?
    
//    var gesture = UIPanGestureRecognizer(target: self, action: #selector(panG))
    
    lazy var tableView: UITableView = {
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
//        tableView.isScrollEnabled = false
//        tableView.addGestureRecognizer(gesture)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.239831388, green: 0.5518291593, blue: 0.7405184507, alpha: 1)
        layoutTopContentView()
        layoutTableView()
        layoutTopLabels()
        configurator.configure(view: self)
        presenter.getWeather()
    }
//
//    var previsY: CGFloat?
//    @objc func panG(recognizer: UIPanGestureRecognizer) {
//        let tr = recognizer.translation(in: view)
//        if previsY == nil {
//            previsY = tr.y
//        } else {
//            tableView.contentInset = UIEdgeInsets(top: Constants.offsetHeight,
//            left: 0, bottom: 0, right: 0)
//            previsY = tr.y
//        }
//    }
    
    func displayWeather(mainScreenWeatherModel: MainScreenWeatherModel) {
        temperatureLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.temperature
        todayLabel.text = MainScreenCurrentWeatherModel.getCurrentDay()
        shortInfoAboutWeatherLabel.text = mainScreenWeatherModel.mainScreenCurrentWeatherModel.sammery
        viewModel = mainScreenWeatherModel
        tableView.reloadData()
    }
    
    func displayErrorMessage(errorMessage: String) {
        
    }
    
    //MARK: - Layout elements
    
    private func layoutTopContentView() {
        view.addSubview(topContentView)
        topContentView.backgroundColor = .clear
        topContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        topContentView.heightAnchor.constraint(equalToConstant: 120).isActive = true
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
    
    private func layoutTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: topContentView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        isTableViewEnabled = true
    }
    
    private func layoutTopLabels() {
        view.addSubview(temperatureLabel)
        temperatureLabel.topAnchor.constraint(equalTo: topContentView.bottomAnchor)
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
    
    private func bottomViewLayout() {
    }
}


//MARK: - TableViewDelegate
extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.row == 0 {
            cell = WeatherByHoursCell()
            (cell as! WeatherByHoursCell).viewModel = viewModel?.mainScreenHourlyWeatherModel
        } else {
            cell = MainTableViewContentCell()
            secondCell = cell
            (cell as! MainTableViewContentCell).delegate = self
            delegate = (cell as! MainScreenViewControllerDelegate)
            (cell as! MainTableViewContentCell).viewModel = viewModel
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return Constants.tableViewCellHeight
        } else {
            return UIScreen.main.bounds.height/1.5
        }
    }
}

//MARK: - ScrollViewDelegate
extension MainScreenViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTableViewEnabled {
            let inset = -scrollView.contentOffset.y
            var alpha = 1 * inset / Constants.offsetHeight
            print(scrollView.contentOffset.y)
            if inset <= 0.1 {
                scrollView.contentOffset = .zero
                scrollView.isScrollEnabled = false
                self.delegate.changeMainTableViewScrollState(isEnable: true)
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
                scrollView.contentOffset = .zero
                print("1 and 2 not")
                self.delegate.changeMainTableViewScrollState(isEnable: true)
            }
        } else {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.todayStaticLabel.alpha = 1
                self.todayLabel.alpha = 1
                self.temperatureLabel.alpha = 1
                scrollView.contentOffset = CGPoint(x: 0, y: -Constants.offsetHeight)
                print("2 yes")
                self.tableView.isScrollEnabled = true
                self.delegate.changeMainTableViewScrollState(isEnable: false)
            }
        }
    }

}

extension MainScreenViewController: MainTableViewContentCellDelegate {
    func changeTableViewScrollState() {
        tableView.isScrollEnabled = true
    }
}

