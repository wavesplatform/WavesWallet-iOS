//
//  DexOrderBookInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexOrderBookInteractorProtocol {

    var pair: DexTraderContainer.DTO.Pair! { get set }
    
    func displayInfo() -> Observable<(DexOrderBook.DTO.DisplayData)>
    
}
