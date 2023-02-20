//
//  AppDelegate.swift
//  Chart
//
//  Created by vi.s.semenov on 17.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = CheckPointsViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}

