//
//  SeedRepository.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

typealias StringSHA512 = String

enum WalletSeedRepositoryError: Error {
    case fail
    case permissionDenied
}

protocol WalletSeedRepositoryProtocol {
    func seed(for address: String, publicKey: String, password: String) -> Observable<DomainLayer.DTO.WalletSeed>
    func saveSeed(for walletSeed: DomainLayer.DTO.WalletSeed, password: String) -> Observable<DomainLayer.DTO.WalletSeed>
    func changePassword(for address: String, publicKey: String, oldPassword: String, newPassword: String) -> Observable<DomainLayer.DTO.WalletSeed>
    func deleteSeed(for address: String) -> Observable<Bool>
}
