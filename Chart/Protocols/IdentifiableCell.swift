//
//  IdentifiableCell.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import UIKit

protocol IdentifiableCell {
    static var reuseIdentifier: String { get }
}

extension IdentifiableCell where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
