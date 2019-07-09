//
//  CleanerWalletManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import Extensions

extension CleanerWalletManager: ReactiveCompatible {}

public struct CleanerWalletManager: TSUD, Codable, Mutating  {
    
    private static let key = "com.waves.cleanwallet.settings"
    
    fileprivate var cleanAccounts: Set<String> = Set<String>()
    
    public init() {
        self.cleanAccounts = .init()
    }
    
    public static var defaultValue: CleanerWalletManager {
        return CleanerWalletManager()
    }
    
    public static var stringKey: String {
        return key
    }

    
    public static func setCleanWallet(accountAddress: String, isClean: Bool) {

        var settings = CleanerWalletManager.get()
        if isClean {
            if settings.cleanAccounts.contains(accountAddress) == false {
                settings.cleanAccounts.insert(accountAddress)
            }
        }
        else {
            settings.cleanAccounts.remove(accountAddress)
        }
        CleanerWalletManager.set(settings)
    }
    
    public static func isCleanWallet(by accountAddress: String) -> Bool {
        return CleanerWalletManager.get().cleanAccounts.contains(accountAddress)
    }
}

extension Reactive where Base == CleanerWalletManager {
    
    public static func setCleanWallet(accountAddress: String, isClean: Bool) -> Observable<Bool> {
        return CleanerWalletManager.rx.get()
            .flatMap({ (settings) -> Observable<Bool> in
                
                var newSettings = settings
                if isClean {
                    if newSettings.cleanAccounts.contains(accountAddress) == false {
                        newSettings.cleanAccounts.insert(accountAddress)
                    }
                }
                else {
                    newSettings.cleanAccounts.remove(accountAddress)
                }
                return CleanerWalletManager.rx.set(newSettings)
            })
    }
    
    public static func isCleanWallet(by accountAddress: String) -> Observable<Bool> {
        return Observable.create({ (subscribe) -> Disposable in

            subscribe.onNext(CleanerWalletManager.get().cleanAccounts.contains(accountAddress))
            subscribe.onCompleted()
            
            return Disposables.create()
        })
    }
}
