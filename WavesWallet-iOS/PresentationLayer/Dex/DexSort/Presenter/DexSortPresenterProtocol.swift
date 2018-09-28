//
//  DexSortPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexSortPresenterProtocol {
    typealias Feedback = (Driver<DexSort.State>) -> Signal<DexSort.Event>
    var interactor: DexSortInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
