//
//  SentryService.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Sentry
import WavesSDKExtension

public class SentryManager {
    
    typealias Event = Sentry.Event
    
    typealias Level = SweetLoggerLevel
    
    private static var shared = SentryManager()
    
    private var client: Client? = nil
    
    init() {
        if let path = Bundle.main.path(forResource: "Sentry-io-Info", ofType: "plist"),
            let dsn = NSDictionary(contentsOfFile: path)?["DSN_URL"] as? String {
            
            do {
                let client = try Client(dsn: dsn)
                self.client = client
                Client.shared = self.client
            } catch let error {
                print("Sentry Not Loading :( \(error)")
            }
            
            do {
                try Client.shared?.startCrashHandler()
            } catch let error {
                print("Centry startCrashHandler :( \(error)")
            }
        }
        
        Client.shared?.enableAutomaticBreadcrumbTracking()
    }
    
    static var currentUser: Sentry.User {
        
        let user = Sentry.User()
        user.userId = UIDevice.uuid
        return user
    }
    
    static func send(event: Event) {
        
        event.timestamp = Date()
        event.user = currentUser
        
            SentryManager.shared.client?.send(event: event, completion: { error in
            
            if let error = error {
                print("SweetLogger :( \(String(describing: error))")
            }
        })
    }
}

