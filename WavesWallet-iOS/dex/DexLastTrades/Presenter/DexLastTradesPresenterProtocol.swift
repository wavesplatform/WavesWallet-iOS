//
//  DexLastTradesPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexLastTradesPresenterProtocol {
    typealias Feedback = (Driver<DexLastTrades.State>) -> Signal<DexLastTrades.Event>
    var interactor: DexLastTradesInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
