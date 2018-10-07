//
//  ReceiveGeneratePresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxFeedback

final class ReceiveGeneratePresenter: ReceiveGeneratePresenterProtocol {
    
    var interactor: ReceiveGenerateInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    
    func system(feedbacks: [ReceiveGeneratePresenter.Feedback], invoiceGenerateInfo: ReceiveInvoive.DTO.GenerateInfo?) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: ReceiveGenerate.State.initialState(invoiceGenerateInfo: invoiceGenerateInfo),
                      reduce: { state, event -> ReceiveGenerate.State in
                        return ReceiveGeneratePresenter.reduce(state: state, event: event)},
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> ReceiveGenerate.State? in
            return state.isNeedCreateInvoice ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveGenerate.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            guard let info = state.invoiceGenerateInfo else { return Signal.empty() }
            return strongSelf.interactor.generateInvoiceAddress(info).map { .invoiceDidCreate($0) }.asSignal(onErrorSignalWith: Signal.empty())

        })
    }
    
    static private func reduce(state: ReceiveGenerate.State, event: ReceiveGenerate.Event) -> ReceiveGenerate.State {
        
        switch event {
        
        case .invoiceDidCreate(let responce):
            
            return state.mutate {
            
                switch responce.result {
                case .success(let info):
                    $0.action = .invoiceDidCreate(info)
                    
                case .error(let error):
                    $0.action = .invoiceDidFailCreate(error)
                }
            }
        }
    }
}

fileprivate extension ReceiveGenerate.State {
    
    static func initialState(invoiceGenerateInfo: ReceiveInvoive.DTO.GenerateInfo?) -> ReceiveGenerate.State {
        
        let isNeedCreate = invoiceGenerateInfo != nil
        return ReceiveGenerate.State(isNeedCreateInvoice: isNeedCreate, invoiceGenerateInfo: invoiceGenerateInfo, action: .none)
    }
    
}
