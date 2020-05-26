//
//  WalletPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

protocol WalletPresenterProtocol {
    typealias Feedback = (Driver<WalletState>) -> Signal<WalletEvent>

    var interactor: WalletInteractorProtocol! { get set }
    var moduleOutput: WalletModuleOutput? { get set }

    func system(feedbacks: [Feedback])
}
