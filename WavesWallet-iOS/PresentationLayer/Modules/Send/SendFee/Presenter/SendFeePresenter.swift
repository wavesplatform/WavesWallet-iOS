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
    static let minWavesSponsoredBalance: Decimal = 1.005
}

final class SendFeePresenter: SendFeePresenterProtocol {
    
    var interactor: SendFeeInteractorProtocol!
    var assetID: String!
    var feeAssetID: String!
    var wavesFee: Money!
    
    private let disposeBag = DisposeBag()
        
    func system(feedbacks: [SendFeePresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(infoQuery())
        
        Driver.system(initialState: SendFee.State.initialState(feeAssetID: feeAssetID,
                                                               wavesFee: wavesFee),
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
            return state.isNeedLoadAssets ? true : nil
            
        }, effects: {[weak self] state -> Signal<SendFee.Event> in
            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf.interactor.assets().map { .didGetAssets($0) }
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

        case .didGetAssets(let assets):

            
            let sectionHeader = SendFee.ViewModel.Section(items: [SendFee.ViewModel.Row.header])
            var assetsRow: [SendFee.ViewModel.Row] = []

            for smartAsset in assets {

                let wavesFee = state.wavesFee
                let fee = smartAsset.asset.isWaves ? wavesFee : SendFee.DTO.calculateSponsoredFee(by: smartAsset.asset, wavesFee: wavesFee)

                let availableBalance = Money(smartAsset.availableBalance, smartAsset.asset.precision)
                let sponsorWavesBalance = Money(smartAsset.sponsorBalance, GlobalConstants.WavesDecimals)
              
                let isActive = (sponsorWavesBalance.decimalValue >= Constants.minWavesSponsoredBalance &&
                                availableBalance.decimalValue >= fee.decimalValue) ||
                    
                                (sponsorWavesBalance.decimalValue >= wavesFee.decimalValue &&
                                availableBalance.decimalValue >= fee.decimalValue &&
                                smartAsset.asset.isMyWavesToken) ||
                    
                                smartAsset.asset.isWaves
                
                assetsRow.append(SendFee.ViewModel.Row.asset(.init(assetBalance: smartAsset,
                                                                   fee: fee,
                                                                   isChecked: smartAsset.assetId == state.feeAssetID,
                                                                   isActive: isActive)))
            }

            let sorted = assetsRow.sorted(by: {$1.asset?.isActive == false})
            
            let sectionAssets = SendFee.ViewModel.Section(items: sorted)
            state.sections = [sectionHeader, sectionAssets]
            state.isNeedLoadAssets = false
            state.action = .update
        }
    }
}

fileprivate extension SendFee.State {
    
    static func initialState(feeAssetID: String, wavesFee: Money) -> SendFee.State {
        return SendFee.State(feeAssetID: feeAssetID,
                             wavesFee: wavesFee,
                             action: .none,
                             isNeedLoadAssets: true,
                             sections: [])
    }
}
