//
//  AppDelegate.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/15/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import UIKit
import Promises

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var connection : Connection?
    var connectionType : ConnectionType = .ELM327
    
    func getConnection(connectionType: ConnectionType) -> Promise<Connection> {
        switch(connectionType) {
        case .ELM327:
            guard let activeConnection = connection else {
                return getELMConnection()
            }
            if (activeConnection.lostConnection()) {
                return getELMConnection()
            }
            return Promise<Connection>(activeConnection as Connection)
        case .Mock:
            return Promise<Connection>(MockConnection())
        }
    }
    
    func getELMConnection() -> Promise<Connection> {
        let elm327 = ELM327()
        return elm327.connectTo(ip: "192.168.0.10").then { (success) -> Promise<Connection> in
            let isoIO = ISO15765(elm327 : elm327)
            let edIO = MQBEurodyne(iso15765: isoIO)
            return elm327.initializeELM().then { (_) -> Promise<Connection> in
                self.connection = ELMConnection(elm327: elm327, eurodyne: edIO, iso15765: isoIO)
                return Promise<Connection>(self.connection! as Connection)
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

