//
//  ChartView.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import UIKit

class ChartView: UIView {
    // MARK: - Properties
    var maxScale: CGFloat = 2
    var minScale: CGFloat = 1
    var points: [Point] = [] {
        didSet {
            renderer.points = points
            updateAxisLabels()
        }
    }
    
    private let renderer = ChartRenderer()
    private let axisLabelConverter = AxisLabelsConverter()
    
    // MARK: - Views
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    
    private let yLabelsContainer = UIView()
    private let minYLabel = UILabel()
    private let maxYLabel = UILabel()
    
    private let xLabelsContainer = UIView()
    private let minXLabel = UILabel()
    private let maxXLabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        renderer.bounds = bounds
        updateAxisLabels()
    }
    
    // MARK: - Private
    private func setup() {
        backgroundColor = .white
        setupYLabelsContainer()
        setupXLabelsContainer()
        setupScrollView()
        setupImageView()
        renderer.delegate = self
        axisLabelConverter.delegate = self
    }
    
    private func setupYLabelsContainer() {
        addSubview(yLabelsContainer)
        yLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            topAnchor.constraint(equalTo: yLabelsContainer.topAnchor),
            leadingAnchor.constraint(equalTo: yLabelsContainer.leadingAnchor),
            bottomAnchor.constraint(equalTo: yLabelsContainer.bottomAnchor),
            yLabelsContainer.widthAnchor.constraint(equalToConstant: 30)
        ])
        setupMinYLabel()
        setupMaxYLabel()
    }
    
    private func setupMinYLabel() {
        yLabelsContainer.addSubview(minYLabel)
        minYLabel.font = .systemFont(ofSize: 6)
        minYLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            minYLabel.bottomAnchor.constraint(equalTo: yLabelsContainer.bottomAnchor),
            minYLabel.trailingAnchor.constraint(equalTo: yLabelsContainer.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupMaxYLabel() {
        yLabelsContainer.addSubview(maxYLabel)
        maxYLabel.font = .systemFont(ofSize: 6)
        maxYLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            maxYLabel.topAnchor.constraint(equalTo: yLabelsContainer.topAnchor),
            maxYLabel.trailingAnchor.constraint(equalTo: yLabelsContainer.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupXLabelsContainer() {
        addSubview(xLabelsContainer)
        xLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            bottomAnchor.constraint(equalTo: xLabelsContainer.bottomAnchor),
            xLabelsContainer.leadingAnchor.constraint(equalTo: yLabelsContainer.trailingAnchor),
            trailingAnchor.constraint(equalTo: xLabelsContainer.trailingAnchor),
            xLabelsContainer.heightAnchor.constraint(equalToConstant: 20)
        ])
        setupMinXLabel()
        setupMaxXLabel()
    }
    
    private func setupMinXLabel() {
        xLabelsContainer.addSubview(minXLabel)
        minXLabel.font = .systemFont(ofSize: 6)
        minXLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            minXLabel.leadingAnchor.constraint(equalTo: xLabelsContainer.leadingAnchor, constant: 8),
            minXLabel.bottomAnchor.constraint(equalTo: xLabelsContainer.bottomAnchor)
        ])
    }
    
    private func setupMaxXLabel() {
        xLabelsContainer.addSubview(maxXLabel)
        maxXLabel.font = .systemFont(ofSize: 6)
        maxXLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            maxXLabel.trailingAnchor.constraint(equalTo: xLabelsContainer.trailingAnchor),
            maxXLabel.bottomAnchor.constraint(equalTo: xLabelsContainer.bottomAnchor)
        ])
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.layer.borderWidth = 3
        scrollView.layer.borderColor = UIColor.black.cgColor
        scrollView.delegate = self
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.leadingAnchor.constraint(
                equalTo: yLabelsContainer.trailingAnchor,
                constant: 8
            ),
            rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: xLabelsContainer.topAnchor,
                constant: -8
            )
        ])
    }
    
    private func setupImageView() {
        scrollView.addSubview(imageView)
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addConstraints([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func updateAxisLabels() {
        axisLabelConverter.update(
            points: points,
            scale: scrollView.zoomScale,
            chartBounds: scrollView.bounds,
            offset: scrollView.contentOffset
        )
    }
    
    private func configureAxisLabels(with axisLabels: AxisLabels?) {
        minYLabel.text = axisLabels?.minY.twoSignsDescription
        maxYLabel.text = axisLabels?.maxY.twoSignsDescription
        minXLabel.text = axisLabels?.minX.twoSignsDescription
        maxXLabel.text = axisLabels?.maxX.twoSignsDescription
    }
}

// MARK: - ChartRendererDelegate
extension ChartView: ChartRendererDelegate {
    func chartRenderer(_ renderer: ChartRenderer, didRenderImage image: UIImage) {
        imageView.image = image
    }
}

// MARK: - AxisLabelsConverterDelegate
extension ChartView: AxisLabelsConverterDelegate {
    func axisLabelsConverter(
        _ converter: AxisLabelsConverter,
        didUpdateLabels labels: AxisLabels?
    ) {
        self.configureAxisLabels(with: labels)
    }
}

// MARK: - UIScrollViewDelegate
extension ChartView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateAxisLabels()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAxisLabels()
    }
}
