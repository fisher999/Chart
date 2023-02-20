//
//  IPointsService.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import Foundation

protocol IPointsService {
    func getPoints(
        count: Int,
        completion: @escaping (Result<[Point], Error>) -> Void
    )
}
