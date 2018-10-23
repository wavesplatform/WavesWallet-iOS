//
//  AccountBalanceRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum AccountBalanceRepositoryError: Error {
    case fail
}

struct AccountBalanceSpecifications {
    struct SortParameters {
        enum Kind {
            case sortLevel
        }

        let ascending: Bool
        let kind: Kind
    }

    let isSpam: Bool?
    let isFavorite: Bool?
    let sortParameters: SortParameters?
}

protocol AccountBalanceRepositoryProtocol {
    
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.AssetBalance]>
    func balance(by id: String, accountAddress: String) -> Observable<DomainLayer.DTO.AssetBalance>

    func balances(by accountAddress: String, specification: AccountBalanceSpecifications) -> Observable<[DomainLayer.DTO.AssetBalance]>

    func saveBalances(_ balances:[DomainLayer.DTO.AssetBalance], accountAddress: String) -> Observable<Bool>
    func saveBalance(_ balance: DomainLayer.DTO.AssetBalance, accountAddress: String) -> Observable<Bool>
    
    func listenerOfUpdatedBalances(by accountAddress: String) -> Observable<[DomainLayer.DTO.AssetBalance]>
}
