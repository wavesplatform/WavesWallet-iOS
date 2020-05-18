//
//  WalletPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

protocol InvestmentPresenterProtocol {
    typealias Feedback = (Driver<InvestmentState>) -> Signal<InvestmentEvent>

    var interactor: InvestmentInteractorProtocol! { get set }
    var moduleOutput: InvestmentModuleOutput? { get set }

    func system(feedbacks: [Feedback])
}
