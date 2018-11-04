//
//  AppDelegate.swift
//  RevolutionaryExamples
//
//  Created by Guilherme Carlos Matuella on 22/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let progressVC = CircularProgressViewController()
        progressVC.tabBarItem = UITabBarItem(title: "Progress", image: nil, tag: 0)
        
        let timerVC = CircularTimerViewController()
        timerVC.tabBarItem = UITabBarItem(title: "Timer", image: nil, tag: 1)
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [progressVC, timerVC]
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
}

