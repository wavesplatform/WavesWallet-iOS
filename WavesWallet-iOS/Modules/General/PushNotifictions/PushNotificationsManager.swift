//
//  PushNotificationsManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 08.11.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift

extension PushNotificationsManager: ReactiveCompatible {}

final class PushNotificationsManager {
    
    static func registerRemoteNotifications() {
        
       UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in

            guard granted else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension Reactive where Base == PushNotificationsManager {

    static func openSettings() -> Observable<Bool> {
        return Observable.create { (subscribe) -> Disposable in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                subscribe.onNext(false)
                subscribe.onCompleted()
                return Disposables.create()
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                subscribe.onNext(true)
                subscribe.onCompleted()
            }
            else {
                subscribe.onNext(false)
                subscribe.onCompleted()
            }
            return Disposables.create()
        }
        .observeOn(MainScheduler.asyncInstance)
    }
    static func getNotificationsStatus() -> Observable<UNAuthorizationStatus> {
          
       return Observable.create { (subscribe) -> Disposable in
           let current = UNUserNotificationCenter.current()
           current.getNotificationSettings(completionHandler: { (settings) in
               
               subscribe.onNext(settings.authorizationStatus)
               subscribe.onCompleted()
           })
           return Disposables.create()
       }
    }
    
    static func registerRemoteNotifications() -> Observable<Bool>  {
           
        return Observable.create { (subscribe) -> Disposable in
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in

                guard granted else {
                    subscribe.onNext(false)
                    subscribe.onCompleted()
                    return
                }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    subscribe.onNext(true)
                    subscribe.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
