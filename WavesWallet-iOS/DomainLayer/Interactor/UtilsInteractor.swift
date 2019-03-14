//
//  UtilsInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/13/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static let minDifference: Int64 = 1000 * 30
}

protocol UtilsInteractorProtocol {
    func saveServerTimestamp() -> Observable<Bool>
}

class UtilsInteractor: UtilsInteractorProtocol {
    
    private var utilsRepository: UtilsRepositoryProtocol
    private var authorizationInteractor: AuthorizationInteractorProtocol
    
    init(utilsRepository: UtilsRepositoryProtocol, authorizationInteractor: AuthorizationInteractorProtocol) {
        self.utilsRepository = utilsRepository
        self.authorizationInteractor = authorizationInteractor
    }
    
    func saveServerTimestamp() -> Observable<Bool> {
        return authorizationInteractor.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Bool> in
            guard let owner = self else { return Observable.empty() }
            return owner.utilsRepository.serverTimestamp(accountAddress: wallet.address)
                .flatMap({ (timestamp) -> Observable<Bool> in
                    
                    let localTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
                    let diff = localTimestamp - timestamp
                    GlobalConstants.Utils.timestampServerDiff = abs(diff) > Constants.minDifference ? diff : 0
                    return Observable.just(true)
                })
        })
        .catchError({ (error) -> Observable<Bool> in
            return Observable.just(false)
        })
    }
}
