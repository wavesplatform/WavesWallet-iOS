//
//  MatcherRepositoryLocal.swift
//  DataLayer
//
//  Created by Pavel Gubin on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDKExtensions

final class MatcherRepositoryLocal: MatcherRepositoryProtocol {
    
    private var internalPublicKeyAccount: PublicKeyAccount?
    
    private var publicKeyAccount: PublicKeyAccount? {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalPublicKeyAccount
        }
        
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalPublicKeyAccount = newValue
        }
    }
    
    private let matcherRepositoryRemote: MatcherRepositoryProtocol

    init(matcherRepositoryRemote: MatcherRepositoryProtocol) {
        self.matcherRepositoryRemote = matcherRepositoryRemote
    }
    
    func matcherPublicKey() -> Observable<PublicKeyAccount> {
        
        if let publicKey = publicKeyAccount {
            return Observable.just(publicKey)
        }

        return matcherPublicKeyShare
            .flatMap({ [weak self] (publicKey) -> Observable<PublicKeyAccount> in
                guard let self = self else { return Observable.empty() }

                self.publicKeyAccount = publicKey
                return Observable.just(publicKey)
            })
    }
    
    private lazy var matcherPublicKeyShare: Observable<PublicKeyAccount> = {
        return matcherRepositoryRemote.matcherPublicKey()
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }()
    
    func settingsIdsPairs() -> Observable<[String]> {
        return matcherRepositoryRemote.settingsIdsPairs()        
    }
}
