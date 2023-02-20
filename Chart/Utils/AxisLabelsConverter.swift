//
//  AxisLabelsConverter.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import Foundation

struct AxisLabels {
    let minX: Float
    let maxX: Float
    let minY: Float
    let maxY: Float
    
}

protocol AxisLabelsConverterDelegate: AnyObject {
    func axisLabelsConverter(
        _ converter: AxisLabelsConverter,
        didUpdateLabels labels: AxisLabels?
    )
}

class AxisLabelsConverter {
    // MARK: - Properties
    weak var delegate: AxisLabelsConverterDelegate?
    
    private let queue = DispatchQueue(label: "com.chart.axisLabelsConverter")
    
    // MARK: - Public
    func update(
        points: [Point],
        scale: CGFloat,
        chartBounds: CGRect,
        offset: CGPoint,
        queue: DispatchQueue = .main
    ) {
        guard !points.isEmpty else {
            queue.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.axisLabelsConverter(
                    self,
                    didUpdateLabels: nil
                )
            }
            return
        }
        queue.async {
            var minX = points[0].x
            var maxX = minX
            var minY = points[0].y
            var maxY = minY
            
            for point in points {
                if point.x < minX {
                    minX = point.x
                }
                
                if point.y < minY {
                    minY = point.y
                }
                
                if point.x > maxX {
                    maxX = point.x
                }
                
                if point.y > maxY {
                    maxY = point.y
                }
            }
            
            let width = abs(maxX - minX)
            let height = abs(maxY - minY)
            
            let x = minX + (Float(offset.x / chartBounds.width) * width / Float(scale))
            let coef = Float(scale) - 1 - Float(offset.y / chartBounds.height)
            let y = minY + coef * height / Float(scale)
            
            let labels = AxisLabels(
                minX: x,
                maxX: x + width / Float(scale),
                minY: y,
                maxY: y + height / Float(scale)
            )
            
            queue.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.axisLabelsConverter(
                    self,
                    didUpdateLabels: labels
                )
            }

        }
    }
}
