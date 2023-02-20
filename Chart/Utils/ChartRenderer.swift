//
//  ChartRenderer.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import UIKit

protocol ChartRendererDelegate: AnyObject {
    func chartRenderer(
        _ renderer: ChartRenderer,
        didRenderImage image: UIImage
    )
}

class ChartRenderer {
    // MARK: - Properties
    weak var delegate: ChartRendererDelegate?
    
    var points: [Point] = [] {
        didSet {
            render()
        }
    }
    
    var scale: CGFloat = 1 {
        didSet {
            render()
        }
    }
    
    var offset: CGPoint = .zero {
        didSet {
            render()
        }
    }
    
    var bounds: CGRect {
        didSet {
            renderer = UIGraphicsImageRenderer(bounds: bounds)
            render()
        }
    }
    
    var strokeColor: CGColor = UIColor.red.cgColor {
        didSet {
            render()
        }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet {
            render()
        }
    }
    
    var isInterpolationEnabled: Bool {
        get {
            return coordinatesConverter.isInterpolationEnabled
        }
        set {
            coordinatesConverter.isInterpolationEnabled = newValue
            render()
        }
    }
    
    var interpolationAxis: CoordinatesConverter.InterpolationAxis {
        get {
            return coordinatesConverter.interpolationAxis
        }
        set {
            coordinatesConverter.interpolationAxis = newValue
            render()
        }
    }
    
    var interpolationAlgorithm: CoordinatesConverter.InterpolationAlgorithm {
        get {
            return coordinatesConverter.interpolationAlgorithm
        }
        set {
            coordinatesConverter.interpolationAlgorithm = newValue
            render()
        }
    }
    
    var insets: UIEdgeInsets = UIEdgeInsets(
        top: 8,
        left: 0,
        bottom: 8,
        right: 0
    ) {
        didSet {
            render()
        }
    }
    
    private var renderer: UIGraphicsImageRenderer
    private let coordinatesConverter: CoordinatesConverter
    
    // MARK: - Init
    init(
        bounds: CGRect = .zero,
        coordinatesConverter: CoordinatesConverter = CoordinatesConverter()
    ) {
        self.bounds = bounds
        self.coordinatesConverter = coordinatesConverter
        self.renderer = UIGraphicsImageRenderer(bounds: bounds)
    }
    
    // MARK: - Public
    func render() {
        coordinatesConverter.convert(
            points: points,
            bounds: bounds,
            insets: insets
        ) { [weak self] points in
            guard let self = self else {
                return
            }
            let image = self.renderImage(points: points)
            self.delegate?.chartRenderer(self, didRenderImage: image)
        }
    }
    
    private func renderImage(points: [CGPoint]) -> UIImage {
        return renderer.image { [weak self] context in
            guard let self = self else { return }
            let cgContext = context.cgContext
            self.configure(with: cgContext)
            self.add(points: points, with: cgContext)
            cgContext.drawPath(using: .stroke)
        }
    }
    
    private func configure(with context: CGContext) {
        context.setStrokeColor(strokeColor)
        context.setLineWidth(lineWidth / scale)
        context.scaleBy(x: scale, y: scale)
    }
    
    private func add(points: [CGPoint], with context: CGContext) {
        guard points.count > 1 else {
            return
        }
        context.move(to: points[0])
        for point in points[1..<points.count] {
            context.addLine(to: point)
        }
    }
}
