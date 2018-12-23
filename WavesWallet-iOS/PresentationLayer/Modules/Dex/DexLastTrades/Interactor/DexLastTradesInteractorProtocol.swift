//
//  DexLastTradesInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexLastTradesInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair! { get set }

    func displayInfo() -> Observable<DexLastTrades.DTO.DisplayData>
    
}
