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
    
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balance(by id: String, accountAddress: String) -> Observable<DomainLayer.DTO.SmartAssetBalance>

    func balances(by accountAddress: String, specification: AccountBalanceSpecifications) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>

    func deleteBalances(_ balances:[DomainLayer.DTO.SmartAssetBalance], accountAddress: String) -> Observable<Bool>
    func saveBalances(_ balances:[DomainLayer.DTO.SmartAssetBalance], accountAddress: String) -> Observable<Bool>
    func saveBalance(_ balance: DomainLayer.DTO.SmartAssetBalance, accountAddress: String) -> Observable<Bool>
    
    func listenerOfUpdatedBalances(by accountAddress: String) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
}
