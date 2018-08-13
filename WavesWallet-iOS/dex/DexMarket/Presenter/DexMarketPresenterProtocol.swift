//
//  DexMarketPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexMarketPresenterProtocol {
    typealias Feedback = (Driver<DexMarket.State>) -> Signal<DexMarket.Event>
    var interactor: DexMarketInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
    var moduleOutput: DexMarketModuleOutput? { get set }

}
