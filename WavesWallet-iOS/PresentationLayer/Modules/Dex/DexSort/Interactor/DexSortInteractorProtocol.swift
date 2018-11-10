//
//  DexSortInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexSortInteractorProtocol {
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]>
    func move(model: DexSort.DTO.DexSortModel, underModel: DexSort.DTO.DexSortModel)
    func move(model: DexSort.DTO.DexSortModel, overModel: DexSort.DTO.DexSortModel)
    func delete(model: DexSort.DTO.DexSortModel)
}
