//
//  NetworkService+PointsService.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import Foundation

extension NetworkService: IPointsService {
    private var getPoints: String {
        return baseURL + "/api/test/points"
    }
    
    func getPoints(
        count: Int,
        completion: @escaping (Result<[Point], Error>) -> Void
    ) {
        let parameters = ["count": count.description]
        getRequest(
            PointsResponse.self,
            url: getPoints,
            parameters: parameters
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.points))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
