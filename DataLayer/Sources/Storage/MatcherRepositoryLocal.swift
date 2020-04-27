//
//  MatcherRepositoryLocal.swift
//  DataLayer
//
//  Created by Pavel Gubin on 12.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDKExtensions

final class MatcherRepositoryLocal: MatcherRepositoryProtocol {
    
    private var internalPublicKeyAccount: DomainLayer.DTO.PublicKey?
    
    private var publicKeyAccount: DomainLayer.DTO.PublicKey? {
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
    
    func matcherPublicKey(serverEnvironment: ServerEnvironment) -> Observable<DomainLayer.DTO.PublicKey> {
        
        if let publicKey = publicKeyAccount {
            return Observable.just(publicKey)
        }

        return matcherRepositoryRemote
            .matcherPublicKey(serverEnvironment: serverEnvironment)
            .flatMap({ [weak self] (publicKey) -> Observable<DomainLayer.DTO.PublicKey> in
                guard let self = self else { return Observable.empty() }

                self.publicKeyAccount = publicKey
                return Observable.just(publicKey)
            })
    }
            
    func settingsIdsPairs(serverEnvironment: ServerEnvironment) -> Observable<[String]> {
        return matcherRepositoryRemote.settingsIdsPairs(serverEnvironment: serverEnvironment)        
    }
}
