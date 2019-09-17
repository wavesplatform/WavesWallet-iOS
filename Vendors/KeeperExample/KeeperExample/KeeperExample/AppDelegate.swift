//
//  AppDelegate.swift
//  KeeperExample
//
//  Created by rprokofev on 04.09.2019.
//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var url: URL?
        
        if let path = launchOptions?[.url] as? String {
            url = URL(string: path)
        }
        
        let sourceApplication = (launchOptions?[.sourceApplication] as? String) ?? ""
        
        
        WavesSDK.initialization(servicesPlugins: .init(data: [],
                                                       node: [],
                                                       matcher: []),
                                enviroment: .init(server: .testNet, timestampServerDiff: 0))
        
        WavesKeeper.initialization(application: .init(name: "Keeper Example", iconUrl: "https://rampaga.ru/_sf/135/72786352.jpg", schemeUrl: "keeperExample"))
        
        
        if let url = url {
            let response = WavesKeeper.shared.decodableResponse(url, sourceApplication: sourceApplication)
            
        }
        
        setupUI()
        
        return true
    }
    
    private func setupUI() {
        
        UITabBar.appearance().tintColor = GlobalConstants.Colors.blue
        UINavigationBar.appearance().barTintColor = GlobalConstants.Colors.blue
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sourceApplication: String = (options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String) ?? ""
        
        WavesKeeper.shared.applicationOpenURL(url, sourceApplication)
        
        
        return true
    }

}

