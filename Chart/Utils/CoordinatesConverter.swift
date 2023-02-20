//
//  CoordinatesConverter.swift
//  Chart
//
//  Created by vi.s.semenov on 17.02.2023.
//

import CoreGraphics.CGGeometry
import Accelerate.vecLib
import simd
import UIKit

class CoordinatesConverter {
    struct ScaleCoordinates {
        let minX: Float
        let minY: Float
        let maxX: Float
        let maxY: Float
    }
    
    enum InterpolationAxis: CaseIterable {
        case horizontal, vertical
    }
    
    enum InterpolationAlgorithm: CaseIterable {
        case linear, quadratic
    }
    
    var isInterpolationEnabled: Bool = true
    var interpolationAxis: InterpolationAxis = .horizontal
    var interpolationAlgorithm: InterpolationAlgorithm = .linear
    var interpolationSteps: Int = 1024
    
    private let queue = DispatchQueue(label: "com.chart.coordinatesConverter")
    
    func convert(
        points: [Point],
        bounds: CGRect,
        insets: UIEdgeInsets,
        completionQueue: DispatchQueue = .main,
        completion: @escaping ([CGPoint]) -> Void
    ) {
        let bounds = bounds.inset(by: insets)
        guard !points.isEmpty else {
            completionQueue.async {
                completion([])
            }
            return
        }
        queue.async { [weak self] in
            guard let self = self else {
                completionQueue.async {
                    completion([])
                }
                return
            }
            
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
            
            let ratioX = bounds.width / CGFloat(width)
            let ratioY = bounds.height / CGFloat(height)
            
            var convertedPoints = points.map {
                CGPoint(
                    x: CGFloat($0.x - minX) * ratioX,
                    y: CGFloat(height - ($0.y - minY)) * ratioY + insets.top
                )
            }
            
            if self.isInterpolationEnabled {
                convertedPoints = self.interpolate(points: convertedPoints)
            }
            
            completionQueue.async {
                completion(convertedPoints)
            }
        }
    }
    
    private func interpolate(
        points: [CGPoint]
    ) -> [CGPoint] {
        if points.count <= 2 { return points }
        
        let n = vDSP_Length(interpolationSteps)
        let stride = vDSP_Stride(1)
        let isHorizontal: Bool = (interpolationAxis == .horizontal)
        
        let values: [Float] = isHorizontal ? points.map({ Float($0.y) }) : points.map({ Float($0.x) })
        let denominator = Float(n) / Float(values.count - 1)
        
        let control: [Float] = (0..<n).map {
            let x = Float($0) / denominator
            return floor(x) + simd_smoothstep(0, 1, simd_fract(x))
        }
        
        var result = [Float](repeating: 0, count: Int(n))
        
        switch interpolationAlgorithm {
        case .linear:
            vDSP_vlint(values, control, stride, &result, stride, n, vDSP_Length(values.count))
        case .quadratic:
            vDSP_vqint(values, control, stride, &result, stride, n, vDSP_Length(values.count))
        }
        
        let pointMinimum: CGFloat = (isHorizontal ? points.first?.x : points.first?.y) ?? 0
        let pointMaximum: CGFloat = (isHorizontal ? points.last?.x : points.last?.y) ?? 0
        let pointStep: CGFloat = (pointMaximum - pointMinimum) / CGFloat(interpolationSteps - 1)
        if isHorizontal == true {
            return result.enumerated().map { (index, value) -> CGPoint in
                CGPoint(
                    x: pointMinimum + (CGFloat(index) * pointStep),
                    y: CGFloat(value)
                )
            }
        } else {
            return result.enumerated().map { (index, value) -> CGPoint in
                CGPoint(
                    x: CGFloat(value),
                    y: pointMinimum + (CGFloat(index) * pointStep)
                )
            }
        }
    }
}
