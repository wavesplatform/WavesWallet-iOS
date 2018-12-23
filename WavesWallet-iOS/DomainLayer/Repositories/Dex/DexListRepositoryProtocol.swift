//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexListRepositoryProtocol {
    func list(by pairs: [DexMarket.DTO.Pair]) -> Observable<[DexList.DTO.Pair]>
}
