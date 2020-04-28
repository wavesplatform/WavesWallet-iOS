//
//  DexOrderBookPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxCocoa
import DomainLayer

protocol DexOrderBookPresenterProtocol {
    typealias Feedback = (Driver<DexOrderBook.State>) -> Signal<DexOrderBook.Event>
    
    var moduleOutput: DexOrderBookModuleOutput? { get set }
    
    func system(feedbacks: [Feedback])
}
