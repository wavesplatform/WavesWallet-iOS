//
//  DexOrderBookPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexOrderBookPresenterProtocol {
    typealias Feedback = (Driver<DexOrderBook.State>) -> Signal<DexOrderBook.Event>
    var interactor: DexOrderBookInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
    var moduleOutput: DexOrderBookModuleOutput? { get set }
    
    var priceAsset: DexTraderContainer.DTO.Asset! { get set }
    var amountAsset: DexTraderContainer.DTO.Asset! { get set }
}
