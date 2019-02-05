//
//  SendFeePresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

private enum Constants {
    static let wavesMinFee: Decimal = 0.001
}

final class SendFeePresenter: SendFeePresenterProtocol {
    
    var interactor: SendFeeInteractorProtocol!
    var assetID: String!
    var feeAssetID: String!
    private let disposeBag = DisposeBag()
        
    func system(feedbacks: [SendFeePresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(infoQuery())
        
        Driver.system(initialState: SendFee.State.initialState(feeAssetID: feeAssetID),
                      reduce: SendFeePresenter.reduce,
                      feedback: newFeedbacks)
        .drive()
        .disposed(by: disposeBag)
    }
    
    static func reduce(state: SendFee.State, event: SendFee.Event) -> SendFee.State {
        
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }
    
    private func infoQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isNeedLoadInfo ? true : nil
            
        }, effects: {[weak self] state -> Signal<SendFee.Event> in
            guard let strongSelf = self else { return Signal.empty() }
            
            return Observable.zip(strongSelf.interactor.assets(),
            strongSelf.interactor.calculateFee(assetID: strongSelf.assetID))
                .map { .didGetInfo($0, $1)}
                .asSignal(onErrorRecover: { (error) -> SharedSequence<SignalSharingStrategy, SendFee.Event> in
                    
                    if let error = error as? NetworkError {
                        return Signal.just(.handleError(error))
                    }
                    return Signal.just(.handleError(NetworkError.error(by: error)))
                })
        })
    }

    static func reduce(state: inout SendFee.State, event: SendFee.Event)  {

        switch event {
        case .handleError(let error):
            state.action = .handleError(error)

        case .didGetInfo(let assets, let fee):

            
            let sectionHeader = SendFee.ViewModel.Section(items: [SendFee.ViewModel.Row.header])
            var assetsRow: [SendFee.ViewModel.Row] = []
            var calculatedFee = fee

            for asset in assets {
                if !asset.isWaves {
                    let sponsorFee = Money(asset.minSponsoredFee, asset.precision).decimalValue
                    let value = (fee.decimalValue / Constants.wavesMinFee) * sponsorFee
                    calculatedFee = Money(value: value, asset.precision)
                }
                assetsRow.append(SendFee.ViewModel.Row.asset(.init(asset: asset,
                                                                   fee: calculatedFee,
                                                                   isChecked: asset.id == state.feeAssetID)))
            }
            
            let sectionAssets = SendFee.ViewModel.Section(items: assetsRow)
            state.sections = [sectionHeader, sectionAssets]
            state.isNeedLoadInfo = false
            state.action = .update
        }
    }
}

fileprivate extension SendFee.State {
    
    static func initialState(feeAssetID: String) -> SendFee.State {
        return SendFee.State(feeAssetID: feeAssetID,
                             action: .none,
                             isNeedLoadInfo: true,
                             sections: [])
    }
}
