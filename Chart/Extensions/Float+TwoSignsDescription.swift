//
//  Float+TwoSignsDescription.swift
//  Chart
//
//  Created by vi.s.semenov on 19.02.2023.
//

import Foundation

extension Float {
    var twoSignsDescription: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self as NSNumber)
    }
}
