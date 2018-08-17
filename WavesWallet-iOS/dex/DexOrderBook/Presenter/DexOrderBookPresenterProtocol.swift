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
    var pair: DexTraderContainer.DTO.Pair! { get set }
    
}
