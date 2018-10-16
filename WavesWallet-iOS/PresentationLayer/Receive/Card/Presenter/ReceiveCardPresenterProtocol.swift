//
//  ReceiveCardPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol ReceiveCardPresenterProtocol {
    typealias Feedback = (Driver<ReceiveCard.State>) -> Signal<ReceiveCard.Event>
    var interactor: ReceiveCardInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
