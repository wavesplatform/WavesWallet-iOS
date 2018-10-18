//
//  SendPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa


final class SendPresenter: SendPresenterProtocol {
    
    var interactor: SendInteractorProtocol!
    private let disposeBag = DisposeBag()

    func system(feedbacks: [SendPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: Send.State.initialState,
                      reduce: { [weak self] state, event -> Send.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
      private func modelsQuery() -> Feedback {
        return react(query: { state -> Send.State? in
            return state.isNeedLoadInfo ? state : nil
        }, effects: { [weak self] state -> Signal<Send.Event> in
            
            
            guard let strongSelf = self else { return Signal.empty() }
            guard let asset = state.selectedAsset else { return Signal.empty() }
            return strongSelf.interactor.gateWayInfo(asset: asset).map {.didGetGatewayInfo($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: Send.State, event: Send.Event) -> Send.State {

        switch event {
        
        case .didChangeAsset(let asset, let isLoadInfo):
            
            return state.mutate {
                $0.action = .none
                $0.isNeedLoadInfo = isLoadInfo
                $0.selectedAsset = asset
            }
            
        case .didChangeRecipient(let recipient):
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.recipient = recipient
                $0.action = .none
            }
            
        case .didGetGatewayInfo(let response):
            return state.mutate {
                
                $0.isNeedLoadInfo = false
                
                switch response.result {
                case .success(let info):
                    $0.action = .didGetInfo(info)
                    
                case .error(let error):
                    $0.action = .didFailInfo(error)
                }
            }
        }
    }
}

fileprivate extension Send.State {
    
    static var initialState: Send.State {
        return Send.State(isNeedLoadInfo: false, action: .none, recipient: "", selectedAsset: nil)
    }
}
