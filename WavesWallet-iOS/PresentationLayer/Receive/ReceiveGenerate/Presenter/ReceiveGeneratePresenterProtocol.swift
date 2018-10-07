//
//  ReceiveGeneratePresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa

protocol ReceiveGeneratePresenterProtocol {
    typealias Feedback = (Driver<ReceiveGenerate.State>) -> Signal<ReceiveGenerate.Event>
    var interactor: ReceiveGenerateInteractorProtocol! { get set }
    func system(feedbacks: [ReceiveGeneratePresenter.Feedback], invoiceGenerateInfo: ReceiveInvoive.DTO.GenerateInfo?)
}
