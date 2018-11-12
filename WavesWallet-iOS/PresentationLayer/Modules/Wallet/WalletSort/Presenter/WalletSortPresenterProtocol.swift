//
//  WalletSortPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol WalletSortPresenterProtocol {
    typealias Feedback = (Driver<WalletSort.State>) -> Signal<WalletSort.Event>
    var interactor: WalletSortInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
