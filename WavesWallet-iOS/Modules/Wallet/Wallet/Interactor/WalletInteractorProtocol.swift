//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

protocol InvestmentInteractorProtocol {
    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func leasing() -> Observable<InvestmentLeasingVM>
    func staking() -> Observable<InvestmentStakingVM>
    func isShowCleanWalletBanner() -> Observable<Bool>
    func setCleanWalletBanner() -> Observable<Bool>
    func isHasAppUpdate() -> Observable<Bool>
}
