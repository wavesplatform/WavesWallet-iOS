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

protocol WalletInteractorProtocol {
    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]>
    func isHasAppUpdate() -> Observable<Bool>
}
