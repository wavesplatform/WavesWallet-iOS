//
//  WidgetSettingsSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxFeedback
import RxSwift
import RxCocoa

private typealias Types = WidgetSettings

protocol MagicRepository {
    func saveSettings() -> Observable<Bool>
    func addAsset()
}

final class WidgetSettingsCardSystem: System<WidgetSettings.State, WidgetSettings.Event> {

    override func initialState() -> State! {
        return WidgetSettings.State(ui: uiState(), core: coreState())
    }
    
    override func internalFeedbacks() -> [Feedback] {        
        return [deleteAsset, changeInterval, changeStyle]
    }
    
    let deleteAsset: Feedback = {
        
        return react(request: { (state) -> DomainLayer.DTO.Asset? in
            
            if case .deleteAsset(let asset) = state.core.action {
                return asset
            }
            
            return nil
            
        }, effects: { (_) -> Signal<Event> in
            
            return Signal.never()
        })
    }()
    
    
    let changeInterval: Feedback = {
        
        return react(request: { (state) -> WidgetSettings.DTO.Interval? in
            
            if case .changeInterval(let interval) = state.core.action {
                return interval
            }
            
            return nil
            
        }, effects: { (_) -> Signal<Event> in
            
            return Signal.never()
        })
    }()
    
    
    let changeStyle: Feedback = {
        
        return react(request: { (state) -> WidgetSettings.DTO.Style? in
            
            if case .changeStyle(let style) = state.core.action {
                return style
            }
            
            return nil
            
        }, effects: { (_) -> Signal<Event> in
            
            return Signal.never()
        })
    }()
    
    /*
     UI Send event -> Delete
     Core -> Delete BD
     
     Если я буду отправлять сообщение напрямую то что ?
     
     UI -> System
     
     System -> Core
     
     Core -> System
     
     System -> UI
 
 */
    
    override func reduce(event: Event, state: inout State) {
        
        switch event {
        case .handlerError(let error):
            break
            
        case .rowDelete(let indexPath):
            
            let row = state
                .ui
                .sections[indexPath.section]
                .rows
                .remove(at: indexPath.row)
            guard let asset = row.asset else { return }
            
            state.core.action = .deleteAsset(asset)
            state.ui.action = .deleteRow(indexPath: indexPath)
            
        case .moveRow(let from, let to):
            
            state.core.action = .none
            state.ui.action = .none
            
        case .addAsset(let asset):
            
            state.core.action = .addAsset(asset)
            state.ui.action = .none
            
        case .changeInterval(let interval):
            state.core.action = .changeInterval(interval)
            state.core.interval = interval
            state.ui.action = .none
            
        case .changeStyle(let style):
            state.core.action = .changeStyle(style)
            state.core.style = style
            state.ui.action = .none
            
        default:
            break
        }
    }
    
    private func uiState() -> State.UI! {
        return WidgetSettings.State.UI(sections: sections(), action: .update)
    }
    
    private func coreState() -> State.Core! {
        return WidgetSettings.State.Core(action: .none,
                                         interval: .m1,
                                         style: .classic)
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
                                     .asset(model)],
                                limitAssets: 9)]
    }
}
