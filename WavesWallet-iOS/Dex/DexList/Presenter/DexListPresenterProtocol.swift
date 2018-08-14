//
//  DexListPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol DexListPresenterProtocol {
    typealias Feedback = (Driver<DexList.State>) -> Signal<DexList.Event>
    var interactor: DexListInteractorProtocol! { get set }
    var moduleOutput: DexListModuleOutput? { get set }

    func system(feedbacks: [Feedback])
}
