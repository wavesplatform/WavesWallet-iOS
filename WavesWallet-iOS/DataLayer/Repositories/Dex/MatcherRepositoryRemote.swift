//
//  MatcherRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class MatcherRepositoryRemote: MatcherRepositoryProtocol {

    private let matcherProvider: MoyaProvider<Matcher.Service.Matcher> = .matcherMoyaProvider()
    private let auth = FactoryInteractors.instance.authorization
    private let environment = FactoryRepositories.instance.environmentRepository
    
    func matcherPublicKey() -> Observable<PublicKeyAccount> {
        
        return self.auth.authorizedWallet().flatMap({ (wallet) -> Observable<PublicKeyAccount> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ (environment) -> Observable<PublicKeyAccount> in

                return self.matcherProvider.rx
                .request(.init(environment: environment))
                .filterSuccessfulStatusAndRedirectCodes()
                .asObservable()
                .flatMap({ (response) -> Observable<PublicKeyAccount>  in
                    
                    do {
                        let key = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? String ?? ""
                        return Observable.just(PublicKeyAccount(publicKey: Base58.decode(key)))
                    }
                    catch let error {
                        return Observable.error(error)
                    }
                })
            })
        })
    }
}
