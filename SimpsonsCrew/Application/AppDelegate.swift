//
//  AppDelegate.swift
//  SimpsonsCrew
//
//  Created by aarthur on 8/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = sb.instantiateInitialViewController()
        
        self.window?.rootViewController = rootVC
        
        return true
    }

}

