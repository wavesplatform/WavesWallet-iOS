//
//  NewWalletSortPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxCocoa

protocol WalletSortPresenterProtocol {
    typealias Feedback = (Driver<WalletSort.State>) -> Signal<WalletSort.Event>
    var interactor: WalletSortInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
