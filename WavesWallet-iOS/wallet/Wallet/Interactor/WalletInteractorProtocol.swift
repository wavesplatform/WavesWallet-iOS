//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol WalletInteractorProtocol {
    func assets() -> AsyncObservable<[WalletTypes.DTO.Asset]>
    func leasing() -> AsyncObservable<WalletTypes.DTO.Leasing>
}
