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

final class MatcherRepositoryLocal: MatcherRepositoryProtocol {
    
    private var publicKeyAccount: PublicKeyAccount?
    private let matcherRepositoryRemote: MatcherRepositoryProtocol
    
    init(matcherRepositoryRemote: MatcherRepositoryProtocol) {
        self.matcherRepositoryRemote = matcherRepositoryRemote
    }
    
    func matcherPublicKey(accountAddress: String) -> Observable<PublicKeyAccount> {
        
        if let publicKey = publicKeyAccount {
            return Observable.just(publicKey)
        }
        return matcherRepositoryRemote.matcherPublicKey(accountAddress: accountAddress)
            .flatMap({ [weak self] (publicKey) -> Observable<PublicKeyAccount> in
                guard let self = self else { return Observable.empty() }
                self.publicKeyAccount = publicKey
                return Observable.just(publicKey)
            })
    }
}
