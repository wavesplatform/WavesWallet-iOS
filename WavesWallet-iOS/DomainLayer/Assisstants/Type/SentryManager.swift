//
//  SentryService.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Sentry

public class SentryManager {
    
    typealias Event = Sentry.Event
    
    typealias Level = SweetLoggerLevel
    
    private static var shared = SentryManager()
    
    init() {
        if let path = Bundle.main.path(forResource: "Sentry.io-Info", ofType: "plist"),
            let dsn = NSDictionary(contentsOfFile: path)?["DSN_URL"] as? String {
            
            do {
                Client.shared = try Client(dsn: dsn)
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
    
    static func send(event: Event) {
        
        event.timestamp = Date()
        event.user?.userId = DeviceId.id
        
        Client.shared?.send(event: event, completion: { error in
            
            if let error = error {
                print("SweetLogger :( \(String(describing: error))")
            }
        })
    }
}

