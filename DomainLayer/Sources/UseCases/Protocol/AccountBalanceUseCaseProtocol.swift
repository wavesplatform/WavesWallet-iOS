//
//  AccountBalanceUseCaseProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public enum AccountBalanceUseCaseError: Error {
    case fail
}

public protocol AccountBalanceUseCaseProtocol {
    func balances() -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balances(by wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func balance(by assetId: String,
                 wallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.SmartAssetBalance>
    func balance(by assetId: String) -> Observable<DomainLayer.DTO.SmartAssetBalance>
}
