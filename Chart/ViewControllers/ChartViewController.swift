//
//  ChartViewController.swift
//  Chart
//
//  Created by vi.s.semenov on 17.02.2023.
//

import UIKit

class ChartViewController: UIViewController {
    // MARK: - Views
    private let tableView = UITableView()
    private let chartView = ChartView()
    private let saveChartButton = UIButton()
    
    // MARK: - Properties
    private var isRotating = false
    private let viewImageSaver = ViewImageSaver()
    
    // MARK: - Model
    private let points: [Point]
    
    // MARK: - Init
    init(points: [Point]) {
        self.points = points
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Private
    private func setup() {
        viewImageSaver.delegate = self
        view.backgroundColor = .white
        setupTableView()
        setupChartView()
        setupSaveChartButton()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            PointCell.self,
            forCellReuseIdentifier: PointCell.reuseIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.5
            )
        ])
    }
    
    private func setupChartView() {
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            chartView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        chartView.points = points
    }
    
    private func setupSaveChartButton() {
        view.addSubview(saveChartButton)
        saveChartButton.translatesAutoresizingMaskIntoConstraints = false
        saveChartButton.setTitle("Save", for: .normal)
        saveChartButton.setTitleColor(.systemBlue, for: .normal)
        view.addConstraints([
            saveChartButton.trailingAnchor.constraint(
                equalTo: chartView.trailingAnchor,
                constant: -8
            ),
            saveChartButton.bottomAnchor.constraint(
                equalTo: chartView.topAnchor,
                constant: -8
            )
        ])
        saveChartButton.addTarget(self, action: #selector(saveChart), for: .touchUpInside)
    }
    
    @objc private func saveChart() {
        viewImageSaver.writeViewToPhotoAlbum(view: chartView)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return points.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PointCell.reuseIdentifier,
            for: indexPath
        ) as? PointCell else {
            return UITableViewCell()
        }
        cell.configure(with: points[indexPath.row])
        return cell
    }
}

// MARK: - ViewImageSaverDelegate
extension ChartViewController: ViewImageSaverDelegate {
    func viewImageSaver(
        _ saver: ViewImageSaver,
        didFinishSavingView view: UIView
    ) {
        if view === self.chartView {
            showAlert(title: "Info", message: "Chart saved successfully")
        }
    }
    
    func viewImageSaver(
        _ saver: ViewImageSaver,
        didFailSavingView view: UIView,
        error: Error
    ) {
        showAlert(title: "Error", message: "Failed to save chart")
    }
}

