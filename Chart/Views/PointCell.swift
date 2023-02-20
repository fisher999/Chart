//
//  PointCell.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import UIKit

class PointCell: UITableViewCell, IdentifiableCell {
    // MARK: - Views
    private let xLabel = UILabel()
    private let yLabel = UILabel()
    private let separator = UIView()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(with point: Point) {
        xLabel.text = point.x.description
        yLabel.text = point.y.description
    }
    
    // MARK: - Setup
    private func setup() {
        setupXLabel()
        setupSeparator()
        setupYLabel()
    }
    
    private func setupXLabel() {
        contentView.addSubview(xLabel)
        xLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            xLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: 16
            ),
            xLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupSeparator() {
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .black
        contentView.addConstraints([
            separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            separator.widthAnchor.constraint(equalToConstant: 2),
            separator.leadingAnchor.constraint(
                equalTo: xLabel.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    private func setupYLabel() {
        contentView.addSubview(yLabel)
        yLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            yLabel.leadingAnchor.constraint(
                equalTo: separator.trailingAnchor,
                constant: 16
            ),
            yLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            yLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            )
        ])
    }
}
