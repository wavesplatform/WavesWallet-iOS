//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class DexInteractor: DexInteractorProtocol {
    
    func dexPairs() -> AsyncObservable<[DexListModel]> {
//        return AsyncObservable.empty()
        return AsyncObservable.just([DexListModel(json: JSON()),
                                     DexListModel(json: JSON())])
    }
}
