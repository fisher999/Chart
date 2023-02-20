//
//  UIViewController+ShowAlert.swift
//  Chart
//
//  Created by vi.s.semenov on 20.02.2023.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertViewController.addAction(
            UIAlertAction(title: "Ok", style: .default)
        )
        present(alertViewController, animated: true)
    }
}
