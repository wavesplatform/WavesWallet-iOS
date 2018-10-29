//
//  DexRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexRepository: DexRepositoryProtocol {

    func pairs() -> Observable<[DexAssetPair]> {
        return Observable.empty()
    }
}
