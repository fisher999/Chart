//
//  Config.swift
//  Chart
//
//  Created by vi.s.semenov on 20.02.2023.
//

import Foundation

class Config {
    private let bundle = Bundle.main
    
    lazy var baseURL: String = {
        guard let baseUrl = bundle.infoDictionary?["baseURL"] as? String,
        !baseUrl.isEmpty else {
            fatalError("Missed `baseURL`. Please set in Info.plist file")
        }
        
        return baseUrl
    }()
}
