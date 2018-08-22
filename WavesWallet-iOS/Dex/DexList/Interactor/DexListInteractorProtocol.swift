//
//  DexListInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexListInteractorProtocol {
    func pairs() -> Observable<[DexList.DTO.Pair]>
    func refreshPairs()
}
