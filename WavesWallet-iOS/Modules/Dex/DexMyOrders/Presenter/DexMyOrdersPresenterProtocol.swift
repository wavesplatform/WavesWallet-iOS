//
//  DexMyOrdersPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexMyOrdersPresenterProtocol {
    
    typealias Feedback = (Driver<DexMyOrders.State>) -> Signal<DexMyOrders.Event>
    var interactor: DexMyOrdersInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
