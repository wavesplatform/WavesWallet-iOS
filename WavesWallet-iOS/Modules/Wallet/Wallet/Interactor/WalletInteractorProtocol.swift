//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

protocol WalletInteractorProtocol {
    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func leasing() -> Observable<WalletTypes.DTO.Leasing>
    func isShowCleanWalletBanner() -> Observable<Bool>
    func setCleanWalletBanner() -> Observable<Bool>
    func isHasAppUpdate() -> Observable<Bool>
}
