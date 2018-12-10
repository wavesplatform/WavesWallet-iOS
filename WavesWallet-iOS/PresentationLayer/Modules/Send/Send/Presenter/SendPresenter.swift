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
        newFeedbacks.append(modelsWavesQuery())
        newFeedbacks.append(assetQuery())
        
        Driver.system(initialState: Send.State.initialState,
                      reduce: { [weak self] state, event -> Send.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func assetQuery() -> Feedback {
        return react(query: { state -> Send.State? in
            return state.scanningAssetID != nil ? state : nil
            
        }, effects: {[weak self] state -> Signal<Send.Event> in
            guard let strongSelf = self else { return Signal.empty() }
            guard let assetID = state.scanningAssetID, assetID.count > 0 else { return Signal.empty() }
            
            return strongSelf.interactor.assetBalance(by: assetID).map { .didGetAssetBalance($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func modelsWavesQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isNeedLoadWaves ? true : nil
        }, effects: {[weak self] state -> Signal<Send.Event> in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.interactor.getWavesBalance().map {.didGetWavesAsset($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func modelsQuery() -> Feedback {
        return react(query: { state -> Send.State? in
            return  state.isNeedLoadInfo ||
                    state.isNeedValidateAliase ||
                    state.isNeedGenerateMoneroAddress ? state : nil
            
        }, effects: { [weak self] state -> Signal<Send.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
           
            if state.isNeedValidateAliase {
                return strongSelf.interactor.validateAlis(alias: state.recipient).map {.validationAliasDidComplete($0)}.asSignal(onErrorSignalWith: Signal.empty())
            }
            
            guard let asset = state.selectedAsset else { return Signal.empty() }
    
            if state.isNeedLoadInfo {
                return strongSelf.interactor.gateWayInfo(asset: asset, address: state.recipient)
                    .map {.didGetGatewayInfo($0)}.asSignal(onErrorSignalWith: Signal.empty())
            }
            else if state.isNeedGenerateMoneroAddress {
                return strongSelf.interactor.generateMoneroAddress(asset: asset, address: state.recipient, paymentID: state.moneroPaymentID)
                    .map {.moneroAddressDidGenerate($0)}.asSignal(onErrorSignalWith: Signal.empty())
            }
           
            return Signal.empty()
        })
    }
    
    private func reduce(state: Send.State, event: Send.Event) -> Send.State {

        switch event {
        
        case .didGetWavesAsset(let asset):
            return state.mutate {
                $0.isNeedLoadWaves = false
                $0.action = .didGetWavesAsset(asset)
            }
            
        case .getGatewayInfo:
            return state.mutate {
                $0.action = .none
                $0.isNeedLoadInfo = true
                $0.isNeedValidateAliase = false
                $0.isNeedGenerateMoneroAddress = false
            }
            
        case .didSelectAsset(let asset, let loadGatewayInfo):
            return state.mutate {
                $0.action = .none
                $0.isNeedLoadInfo = loadGatewayInfo
                $0.isNeedValidateAliase = false
                $0.isNeedGenerateMoneroAddress = false
                $0.selectedAsset = asset
            }
    
        case .didChangeRecipient(let recipient):
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedValidateAliase = false
                $0.isNeedGenerateMoneroAddress = false
                $0.recipient = recipient
                $0.action = .none
            }
            
        case .didChangeMoneroPaymentID(let paymentID):
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedValidateAliase = false
                $0.isNeedGenerateMoneroAddress = true
                $0.moneroPaymentID = paymentID
                $0.action = .none
            }
            
        case .moneroAddressDidGenerate(let response):
            return state.mutate {
                $0.isNeedGenerateMoneroAddress = false
                $0.isNeedLoadInfo = false
                $0.isNeedValidateAliase = false

                switch response.result {
                case .success(let address):
                    $0.action = .didGenerateMoneroAddress(address)
                    
                case .error(let error):
                    $0.action = .didFailGenerateMoneroAddress(error)
                }
            }
            
        case .didGetGatewayInfo(let response):
            return state.mutate {
                
                $0.isNeedLoadInfo = false
                $0.isNeedValidateAliase = false
                $0.isNeedGenerateMoneroAddress = false
                
                switch response.result {
                case .success(let info):
                    $0.action = .didGetInfo(info)
                    
                case .error(let error):
                    $0.action = .didFailInfo(error)
                }
            }

        case .checkValidationAlias:
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedValidateAliase = true
                $0.action = .none
            }
            
        case .validationAliasDidComplete(let isValiadAlias):
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedValidateAliase = false
                $0.action = .aliasDidFinishCheckValidation(isValiadAlias)
            }
        
        case .getAssetById(let assetID):
            return state.mutate {
                $0.scanningAssetID = assetID
                $0.action = .none
            }
        
        case .cancelGetingAsset:
            return state.mutate {
                $0.scanningAssetID = ""
                $0.action = .none
            }
            
        case .didGetAssetBalance(let asset):
            return state.mutate {
                $0.scanningAssetID = nil
                $0.action = .didGetAssetBalance(asset)
            }
        }
    }
}

fileprivate extension Send.State {
    
    static var initialState: Send.State {
        return Send.State(isNeedLoadInfo: false,
                          isNeedValidateAliase: false,
                          isNeedLoadWaves: true,
                          isNeedGenerateMoneroAddress: false,
                          action: .none,
                          recipient: "",
                          moneroPaymentID: "",
                          selectedAsset: nil,
                          scanningAssetID: nil)
    }
}
