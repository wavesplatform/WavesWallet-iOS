//
//  DexInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexInteractorProtocol {
    func dexPairs() -> AsyncObservable<[DexListModel]>

}
