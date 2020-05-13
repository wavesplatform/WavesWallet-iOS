//
//  AccountBalanceRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol AccountBalanceRepositoryProtocol {

    func balances(by serverEnviroment: ServerEnvironment,
                  wallet: DomainLayer.DTO.SignedWallet) -> Observable<[AssetBalance]>
    
    func balance(by serverEnviroment: ServerEnvironment,
                 assetId: String,
                 wallet: DomainLayer.DTO.SignedWallet) -> Observable<AssetBalance>
}
