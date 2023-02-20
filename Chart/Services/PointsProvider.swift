//
//  PointsProvider.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import Foundation

protocol PointsProviderDelegate: AnyObject {
    func pointsProvider(
        _ provider: PointsProvider,
        didProvidePointsSuccess points: [Point]
    )
    func pointsProvider(
        _ service: PointsProvider,
        didFailProvidePointsWithError error: Error
    )
}

class PointsProvider {
    // MARK: - Properties
    weak var delegate: PointsProviderDelegate?
    
    private let pointsService: IPointsService = NetworkService()
    
    // MARK: - Public
    func provide(numberOfPoints: Int) {
        pointsService.getPoints(count: numberOfPoints) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let points):
                self.delegate?.pointsProvider(
                    self,
                    didProvidePointsSuccess: points.sorted { $0.x < $1.x }
                )
            case .failure(let error):
                self.delegate?.pointsProvider(self, didFailProvidePointsWithError: error)
            }
        }
    }
}
