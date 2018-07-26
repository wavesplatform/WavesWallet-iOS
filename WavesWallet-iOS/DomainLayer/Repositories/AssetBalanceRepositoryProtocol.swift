//
//  AccountBalanceRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol AssetBalanceRepositoryProtocol {
    func balances() -> Observable<[AssetBalanceProtocol]>    
}
