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

protocol AccountBalanceRepositoryProtocol {
    
    func balances(by accountAddress: String, privateKey: PrivateKeyAccount) -> Observable<[DomainLayer.DTO.AssetBalance]>

    func balance(by id: String) -> Observable<DomainLayer.DTO.AssetBalance>

    func saveBalances(_ balances:[DomainLayer.DTO.AssetBalance]) -> Observable<Bool>
    func saveBalance(_ balance: DomainLayer.DTO.AssetBalance) -> Observable<Bool>
    
    var listenerOfUpdatedBalances: Observable<[DomainLayer.DTO.AssetBalance]> { get }
}
