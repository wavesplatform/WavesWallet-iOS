//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol WalletInteractorProtocol {
    func assets() -> Observable<[WalletTypes.DTO.Asset]>
    func leasing() -> Observable<WalletTypes.DTO.Leasing>

    func refreshAssets()
    func refreshLeasing()
}
