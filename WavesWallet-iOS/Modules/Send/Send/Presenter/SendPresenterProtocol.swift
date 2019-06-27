//
//  SendPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol SendPresenterProtocol {

    typealias Feedback = (Driver<Send.State>) -> Signal<Send.Event>
    var interactor: SendInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}
