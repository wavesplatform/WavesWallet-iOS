//
//  WalletsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

enum WalletsRepositoryError: Error {
    case fail
}

protocol WalletsRepositoryProtocol {

    func wallet(by publicKey: String) -> Observable<DomainLayer.DTO.Wallet>

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]>
    func saveWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
    func removeWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool>
}
