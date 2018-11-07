//
//  StartLeasingPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol StartLeasingPresenterProtocol {
    typealias Feedback = (Driver<StartLeasing.State>) -> Signal<StartLeasing.Event>
    var interactor: StartLeasingInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
    
    var moduleOutput: StartLeasingModuleOutput? { get set }

}
