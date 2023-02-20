//
//  CheckPointsViewController.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import UIKit

class CheckPointsViewController: UIViewController {
    // MARK: - Views
    private let informationLabel = UILabel()
    private let textField = UITextField()
    private let checkPointsButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Properties
    private let pointsProvider = PointsProvider()
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .white
        setupInformationLabel()
        setupTextField()
        setupCheckpointsButton()
        setupActivityIndicator()
        pointsProvider.delegate = self
    }
    
    private func setupInformationLabel() {
        view.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.numberOfLines = 0
        informationLabel.text = "Welcome to the Chart test assignment.\n Please type number of points and tap `lets go` to get chart"
        let layoutGuide = view.safeAreaLayoutGuide
        view.addConstraints([
            informationLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            informationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            informationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        view.addConstraints([
            textField.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCheckpointsButton() {
        view.addSubview(checkPointsButton)
        checkPointsButton.translatesAutoresizingMaskIntoConstraints = false
        checkPointsButton.backgroundColor = .black
        checkPointsButton.setTitle("Let's go", for: .normal)
        checkPointsButton.setTitleColor(.white, for: .normal)
        checkPointsButton.clipsToBounds = true
        checkPointsButton.layer.cornerRadius = 8
        view.addConstraints([
            checkPointsButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            checkPointsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        checkPointsButton.addTarget(
            self,
            action: #selector(didTapCheckpointsButton),
            for: .touchUpInside
        )
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        view.addConstraints([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Actions
extension CheckPointsViewController {
    @objc private func didTapCheckpointsButton() {
        guard let text = textField.text, let numberOfPoints = Int(text) else {
            showAlert(title: "Info", message: "Type number of points")
            return
        }
        textField.resignFirstResponder()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        pointsProvider.provide(numberOfPoints: numberOfPoints)
    }
}

// MARK: - PointsProviderDelegate
extension CheckPointsViewController: PointsProviderDelegate {
    func pointsProvider(
        _ service: PointsProvider,
        didFailProvidePointsWithError error: Error
    ) {
        activityIndicator.stopAnimating()
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func pointsProvider(
        _ provider: PointsProvider,
        didProvidePointsSuccess points: [Point]
    ) {
        activityIndicator.stopAnimating()
        let viewController = ChartViewController(points: points)
        present(viewController, animated: true)
    }
}
