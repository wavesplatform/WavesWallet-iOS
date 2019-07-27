//
//  MarketPulseWidgetPresenter.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxFeedback
import WavesSDK

protocol MarketPulseWidgetPresenterProtocol {
    typealias Feedback = (Driver<MarketPulse.State>) -> Signal<MarketPulse.Event>
    var interactor: MarketPulseWidgetInteractorProtocol! { get set }
    
    func system(feedbacks: [MarketPulseWidgetPresenter.Feedback], settings: MarketPulse.DTO.Settings)
}

final class MarketPulseWidgetPresenter: MarketPulseWidgetPresenterProtocol {
    
    var interactor: MarketPulseWidgetInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    func system(feedbacks: [MarketPulseWidgetPresenter.Feedback], settings: MarketPulse.DTO.Settings) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(queryAssets())
        
        Driver.system(initialState: MarketPulse.State.initialState(settings: settings),
                      reduce: MarketPulseWidgetPresenter.reduce,
                      feedback: newFeedbacks)
        .drive()
        .disposed(by: disposeBag)
    }
    
    private func queryAssets() -> Feedback {
        return react(request: { state -> MarketPulse.State? in
            return state.isNeedRefreshing ? state : nil
        }, effects: { [weak self] _ -> Signal<MarketPulse.Event> in
            guard let self = self else { return Signal.empty() }
            return self.interactor.pairs().map {.setAssets($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private static func reduce(state: MarketPulse.State, event: MarketPulse.Event) -> MarketPulse.State {
        
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }
    
    private static func reduce(state: inout MarketPulse.State, event: MarketPulse.Event) {
        switch event {
        case .readyView:
            state.isNeedRefreshing = true
            
        case .refresh:
            state.isNeedRefreshing = true
            state.action = .none
            
        case .changeCurrency(let currency):
            state.currency = currency
            state.models = mapAssetModels(assets: state.assets, settings: .init(currency: currency,
                                                                                isDarkMode: state.isDarkMode))
            state.action = .update
            
        case .setAssets(let assets):
            state.isNeedRefreshing = false
            
            state.assets = assets
            state.models = mapAssetModels(assets: assets, settings: .init(currency: state.currency,
                                                                                    isDarkMode: state.isDarkMode))
            state.action = .update
        }
    }
}

private extension MarketPulseWidgetPresenter {
    
    static func mapAssetModels(assets: [MarketPulse.DTO.Asset], settings: MarketPulse.DTO.Settings) -> [MarketPulse.ViewModel.Row] {

        guard let wavesUSDAsset = assets.first(where: {$0.id == MarketPulse.usdAssetId}) else { return [] }
        guard let wavesEURAsset = assets.first(where: {$0.id == MarketPulse.eurAssetId}) else { return [] }
        
        let wavesPrice = settings.currency == .usd ? wavesUSDAsset.lastPrice : wavesEURAsset.lastPrice
        
        let filteredAsset = assets.filter {$0.id != MarketPulse.eurAssetId && $0.id != MarketPulse.usdAssetId }
        
        return filteredAsset.map { asset in
            
            var price: Double = 0
            var percent: Double = 0
            
            if asset.id == WavesSDKConstants.wavesAssetId {
                let wavesAsset = settings.currency == .usd ? wavesUSDAsset : wavesEURAsset
                let deltaPercent = (wavesAsset.lastPrice - wavesAsset.firstPrice) * 100
                percent = deltaPercent != 0 ? deltaPercent / wavesAsset.lastPrice : 0
                price = wavesPrice
            }
            else {
                let deltaPercent = (asset.lastPrice - asset.firstPrice) * 100
                percent = deltaPercent != 0 ? deltaPercent / asset.lastPrice : 0
                price = asset.volumeWaves / asset.volume * wavesPrice
            }
            
            return MarketPulse.ViewModel.Row.model(MarketPulse.DTO.UIAsset(icon: asset.icon,
                                                                           hasScript: asset.hasScript,
                                                                           isSponsored: asset.isSponsored,
                                                                           name: asset.name,
                                                                           price: price,
                                                                           percent: percent,
                                                                           currency: settings.currency,
                                                                           isDarkMode: settings.isDarkMode))
        }
    }
}

fileprivate extension MarketPulse.State {
    static func initialState(settings: MarketPulse.DTO.Settings) -> MarketPulse.State {
        return MarketPulse.State(isNeedRefreshing: false,
                                 action: .none,
                                 models: [],
                                 assets: [],
                                 currency: settings.currency,
                                 isDarkMode: settings.isDarkMode)
    }
}
