//
//  WalletsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public struct WalletsRepositorySpecifications {
    public let isLoggedIn: Bool
}

public protocol WalletsRepositoryProtocol {
    
    func wallet(by publicKey: String) -> Observable<Wallet>
    func wallets() -> Observable<[Wallet]>
    func wallets(specifications: WalletsRepositorySpecifications) -> Observable<[Wallet]>

    func saveWallet(_ wallet: Wallet) -> Observable<Wallet>
    func saveWallets(_ wallets: [Wallet]) -> Observable<[Wallet]>

    func removeWallet(_ wallet: Wallet) -> Observable<Bool>

    func listenerWallet(by publicKey: String) -> Observable<Wallet>


    func walletEncryption(by publicKey: String) -> Observable<WalletEncryption>

    func saveWalletEncryption(_ walletEncryption: WalletEncryption) -> Observable<WalletEncryption>

    func removeWalletEncryption(by publicKey: String) -> Observable<Bool>;
}
