//
//  CleanerWalletManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension
import RxSwift

extension CleanerWalletManagerBanner: ReactiveCompatible {}

struct CleanerWalletManagerBanner: TSUD, Codable, Mutating {
    private static let key = "com.waves.cleanwalletbanner.settings"

    fileprivate var cleanAccounts: Set<String> = Set<String>()
    
    init() {
        self.cleanAccounts = .init()
    }
    
    static var defaultValue: CleanerWalletManagerBanner {
        return CleanerWalletManagerBanner()
    }
    
    static var stringKey: String {
        return key
    }
}

extension Reactive where Base == CleanerWalletManagerBanner {
    
    static func setCleanWalletBanner(accountAddress: String, isClean: Bool) -> Observable<Bool> {
        return CleanerWalletManagerBanner.rx.get()
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
                return CleanerWalletManagerBanner.rx.set(newSettings)
            })
    }
    
    static func isCleanWalletBanner(by accountAddress: String) -> Observable<Bool> {
        return Observable.create({ (subscribe) -> Disposable in
        
            subscribe.onNext(CleanerWalletManagerBanner.get().cleanAccounts.contains(accountAddress))
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
}
