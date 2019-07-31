//
//  WidgetSettingsSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

private typealias Types = WidgetSettings

final class WidgetSettingsCardSystem: System<WidgetSettings.State, WidgetSettings.Event> {

    override func initialState() -> State! {
        return WidgetSettings.State(ui: uiState(), core: coreState())
    }
    
    override func internalFeedbacks() -> [Feedback] {        
        return []
    }
    
    override func reduce(event: Event, state: inout State) {
        switch event {
        case .handlerError(let error):
            <#code#>
        default:
            <#code#>
        }
    }
    
    private func uiState() -> State.UI! {
        return WidgetSettings.State.UI(sections: sections(), action: .update)
    }
    
    private func coreState() -> State.Core! {
        return WidgetSettings.State.Core(action: .none)
    }
    
    private func sections() -> [Types.Section] {
        
        let assetWaves = DomainLayer.DTO.Asset.mockWaves()
        
        let model = WidgetSettingsAssetCell.Model(asset: assetWaves, isLock: true)
        
        let model2 = WidgetSettingsAssetCell.Model(asset: DomainLayer.DTO.Asset.mockBTC(), isLock: false)
        
        
        return [Types.Section(rows: [.asset(model),
                                     .asset(model2),
                                     .asset(model),
                                     .asset(model),
                                     .asset(model2),
                                     .asset(model),
                                     .asset(model),
                                     .asset(model2),
                                     .asset(model),
                                     .asset(model),
                                     .asset(model2),
                                     .asset(model),
                                     .asset(model)])]
    }
    
//    WidgetSettingsAssetCell

}
