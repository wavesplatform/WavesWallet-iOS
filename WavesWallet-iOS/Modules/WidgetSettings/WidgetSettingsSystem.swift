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
import Extensions
import WavesSDKExtensions

private typealias Types = WidgetSettings

//TODO: Вывод Ошибки
//TODO: Memory warning (?)
//TODO: Некрасиво закрываются Карточки

final class WidgetSettingsCardSystem: System<WidgetSettings.State, WidgetSettings.Event> {

    private lazy var widgetSettingsUseCase: WidgetSettingsUseCaseProtocol = UseCasesFactory.instance.widgetSettings
    
    override func initialState() -> State! {
        return WidgetSettings.State(ui: uiState(minCountAssets: DomainLayer.DTO.Widget.minCountAssets,
                                                maxCountAssets: DomainLayer.DTO.Widget.maxCountAssets),
                                    core: coreState(minCountAssets: DomainLayer.DTO.Widget.minCountAssets,
                                                    maxCountAssets: DomainLayer.DTO.Widget.maxCountAssets))
    }
    
    override func internalFeedbacks() -> [Feedback] {        
        return [deleteAsset, changeInterval, changeStyle, settings, update, sortAssets]
    }
    
    private lazy var deleteAsset: Feedback = {
        
        return react(request: { (state) -> DomainLayer.DTO.Asset? in
            
            if case .deleteAsset(let asset) = state.core.action {
                return asset
            }
            
            return nil
            
        }, effects: { [weak self] (asset) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            return self
                .widgetSettingsUseCase
                .removeAsset(asset)
                .map { _ in Types.Event.none }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }()
    
    private lazy var changeInterval: Feedback = {
        
        return react(request: { (state) -> DomainLayer.DTO.Widget.Interval? in
            
            if case .changeInterval(let interval) = state.core.action {
                return interval
            }
            
            return nil
            
        }, effects: { [weak self] (interval) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            return self
                .widgetSettingsUseCase
                .changeInterval(interval)
                .map { _ in Types.Event.none }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }()
    
    private lazy var changeStyle: Feedback = {
        
        return react(request: { (state) -> DomainLayer.DTO.Widget.Style? in
            
            if case .changeStyle(let style) = state.core.action {
                return style
            }
            
            return nil
            
        }, effects: { [weak self] (style) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            return self
                .widgetSettingsUseCase
                .changeStyle(style)
                .map { _ in Types.Event.none }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }()
    
    private lazy var sortAssets: Feedback = {
        
        return react(request: { (state) -> [String: Int]? in
            
            if case .sortAssets(let sortMap) = state.core.action {
                return sortMap
            }
            
            return nil
            
        }, effects: { [weak self] (sortMap) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            return self
                .widgetSettingsUseCase
                .sortAssets(sortMap)
                .map { _ in Types.Event.none }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }()
    
    private struct UpdateQuery: Equatable {
        let assets: [DomainLayer.DTO.Asset]
        let sortMap: [String: Int]
        let style: DomainLayer.DTO.Widget.Style
        let interval: DomainLayer.DTO.Widget.Interval
    }
    
    private lazy var update: Feedback = {
        
        return react(request: { (state) -> UpdateQuery? in
            
            if case .updateSettings = state.core.action {
                return UpdateQuery(assets: state.core.assets,
                                   sortMap: state.core.sortMap,
                                   style: state.core.style,
                                   interval: state.core.interval)
            }
            
            return nil
            
        }, effects: { [weak self] (query) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            let sortMap = query.sortMap
            let assets = query.assets.sorted(by: { (sortMap[$0.id] ?? 0) < (sortMap[$1.id] ?? 0) })
            
            return self
                .widgetSettingsUseCase
                .saveSettings(DomainLayer.DTO.Widget.Settings.init(assets: assets,
                                                                   style: query.style,
                                                                   interval: query.interval))
                .map { Types.Event.settings($0) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }()
    
    private lazy var settings: Feedback = {
        
        return react(request: { (state) -> Bool? in
            
            if case .settings = state.core.action {
                print("state.core.action \(state.core.action)")
                return true
            }
            
            return nil
            
        }, effects: { [weak self] (_) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            return self
                .widgetSettingsUseCase
                .settings()
                .map { Types.Event.settings($0) }
                .asSignal(onErrorRecover: { error in
                    return Signal.empty()
                })
        })
    }()

    override func reduce(event: Event, state: inout State) {
        
        switch event {
            
        case .none:
            state.core.action = .none
            state.ui.action = .none
            
        case .viewDidAppear:
            
            guard state.core.isInitial == false  else { return }
            
            state.core.isInitial = true
            state.core.action = .settings
            state.ui.sections = skeletonSections(maxCountAssets: state.core.maxCountAssets)
            state.ui.action = .update
        
        case .settings(let settings):
            
            state.core.action = .none
            state.core.interval = settings.interval
            state.core.style = settings.style
            state.core.assets = settings.assets
            state.core.sortMap = settings.assets.enumerated().reduce(into: [String: Int].init(),
                                                                     { $0[$1.element.id] = $1.offset })
            
            state.ui.sections = sections(assets: settings.assets, minCountAssets: state.core.minCountAssets, maxCountAssets: state.core.maxCountAssets)
            state.ui.isEditing = true
            state.ui.action = .update
            
        case .handlerError(let error):
            //TODO: Error
            break
            
        case .rowDelete(let indexPath):
            
            let row = state.ui.sections[indexPath.section].rows
                .remove(at: indexPath.row)

            guard let asset = row.asset else { return }

            state.core.assets.removeAll(where: { $0.id == asset.id } )
            state.core.action = .deleteAsset(asset)
            
            if state.core.assets.count > state.core.minCountAssets {
                state.ui.action = .deleteRow(indexPath: indexPath)
            } else {
                state.ui.sections = sections(assets: state.core.assets, minCountAssets: state.core.minCountAssets, maxCountAssets: state.core.maxCountAssets)
                state.ui.action = .update
            }
            
        case .moveRow(let from, let to):
            
            guard let fromAsset = state.ui[from].asset else { return }
            guard let toAsset = state.ui[to].asset else { return }
            
            
            let fromLevel = state.core.sortMap[fromAsset.id]
            let toLevel = state.core.sortMap[toAsset.id]
            
            state.core.sortMap[fromAsset.id] = toLevel
            state.core.sortMap[toAsset.id] = fromLevel
            state.core.action = .sortAssets(state.core.sortMap)
            
            state.ui.action = .none
            
        case .syncAssets(let assets):
            
            if state.core.assets.elementsEqual(assets, by: { $0.id == $1.id }) {
                state.core.action = .none
                return
            }
            
            state.ui.sections = skeletonSections(maxCountAssets: state.core.maxCountAssets)
            state.ui.isEditing = false
            state.ui.action = .update
            
            state.core.assets = assets
            state.core.action = .updateSettings
            
        case .changeInterval(let interval):
            
            state.core.action = .changeInterval(interval)
            state.core.interval = interval
            state.ui.action = .none
            
        case .changeStyle(let style):
            state.core.action = .changeStyle(style)
            state.core.style = style
            state.ui.action = .none
        }
    }
    
    private func uiState(minCountAssets: Int, maxCountAssets: Int) -> State.UI! {
        return WidgetSettings.State.UI(sections: sections(assets: [],
                                                          minCountAssets: minCountAssets,
                                                          maxCountAssets: maxCountAssets),
                                       action: .update,
                                       isEditing: false)
    }
    
    private func coreState(minCountAssets: Int, maxCountAssets: Int) -> State.Core! {
        return WidgetSettings.State.Core(action: .none,
                                         assets: [],
                                         minCountAssets: minCountAssets,
                                         maxCountAssets: maxCountAssets,
                                         interval: .m1,
                                         style: .classic,
                                         sortMap: .init(),
                                         isInitial: false)
    }
    
    private func sections(assets: [DomainLayer.DTO.Asset], minCountAssets: Int, maxCountAssets: Int) -> [Types.Section] {
        
        let isNeedLock = assets.count == minCountAssets
        
        let rows = assets.enumerated().map { Types.Row.asset(.init(asset: $0.element,
                                                                   isLock: isNeedLock)) }
        
        return [Types.Section(rows: rows, limitAssets: maxCountAssets)]
    }
    
    private func skeletonSections(maxCountAssets: Int) -> [Types.Section] {
        
        return [Types.Section(rows: [.skeleton,
                                     .skeleton], limitAssets: maxCountAssets)]
    }
}
