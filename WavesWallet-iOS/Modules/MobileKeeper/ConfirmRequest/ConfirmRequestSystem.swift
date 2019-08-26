//
//  ConfirmRequestSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxFeedback
import RxSwift
import RxCocoa
import Extensions
import WavesSDKExtensions

private typealias Types = ConfirmRequest

final class ConfirmRequestSystem: System<ConfirmRequest.State, ConfirmRequest.Event> {
    
    private lazy var widgetSettingsUseCase: WidgetSettingsUseCaseProtocol = UseCasesFactory.instance.widgetSettings
    
    override func initialState() -> State! {
        return ConfirmRequest.State(ui: uiState(),
                                    core: coreState())
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return []
    }
    
//    private lazy var deleteAsset: Feedback = {
//
//        return react(request: { (state) -> DomainLayer.DTO.Asset? in
//
//            if case .deleteAsset(let asset) = state.core.action {
//                return asset
//            }
//
//            return nil
//
//        }, effects: { [weak self] (asset) -> Signal<Event> in
//
//            guard let self = self else { return Signal.never() }
//
//            return self
//                .widgetSettingsUseCase
//                .removeAsset(asset)
//                .map { _ in Types.Event.none }
//                .asSignal(onErrorRecover: { _ in
//                    return Signal.empty()
//                })
//        })
//    }()
    

    override func reduce(event: Event, state: inout State) {
        
        switch event {
            
        case .none:
            break
            
        case .viewDidAppear:
            break
        }
    }
    
    private func uiState() -> State.UI! {
        return ConfirmRequest.State.UI(sections: sections(),
                                       action: .update)
    }
    
    private func coreState() -> State.Core! {
        return State.Core(action: .none)
    }
    
    private func sections() -> [Types.Section] {
        
        let rows = [Types.Row.kind, Types.Row.fromTo]
        
        return [Types.Section(rows: rows)]
    }
}
