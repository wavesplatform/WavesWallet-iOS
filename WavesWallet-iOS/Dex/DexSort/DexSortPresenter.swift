//
//  DexSortPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol DexSortPresenterProtocol {
    typealias Feedback = (Driver<DexSort.State>) -> Signal<DexSort.Event>
    
    func system(feedbacks: [Feedback])
}

final class DexSortPresenter: DexSortPresenterProtocol {
    
    private let interactor: DexSortInteractorProtocol = DexSortInteractor()

    func system(feedbacks: [DexSortPresenterProtocol.Feedback]) {
        
    }
}
