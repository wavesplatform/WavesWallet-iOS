//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexListInteractor: DexListInteractorProtocol {
   
    func pairs() -> Observable<[DexList.DTO.Pair]> {
        return Observable.just([])
    }
}

