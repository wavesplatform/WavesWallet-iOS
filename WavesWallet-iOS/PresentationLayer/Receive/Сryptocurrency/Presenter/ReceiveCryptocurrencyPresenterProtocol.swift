//
//  ReceiveCryptocurrencyPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol ReceiveCryptocurrencyPresenterProtocol {
    typealias Feedback = (Driver<ReceiveCryptocurrency.State>) -> Signal<ReceiveCryptocurrency.Event>
    var interactor: ReceiveCryptocurrencyInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
