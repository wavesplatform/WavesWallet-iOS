//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol WalletInteractorProtocol {
    func assets() -> Observable<Void>
}

final class WalletInteractor: WalletInteractorProtocol {
    func assets() -> Observable<Void> {
        return Observable<Void>.never()
    }
}
