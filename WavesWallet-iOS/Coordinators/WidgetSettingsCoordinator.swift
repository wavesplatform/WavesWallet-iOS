//
//  WidgetSettingsCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 01.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import WavesSDKExtensions
import DomainLayer
import Extensions

private enum StatePopover {
    
    case none
    case syncAssets([DomainLayer.DTO.Asset])
}

private enum WidgetState {
    case none
    case callback((([DomainLayer.DTO.Asset]) -> Void))
}

final class WidgetSettingsCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    weak var parent: Coordinator?
    
    private var navigationRouter: NavigationRouter
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var statePopover: StatePopover = .none
    
    private var widgetState: WidgetState = .none
    
    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
        
        switch self.statePopover {
        case .syncAssets(let assets):
            if case .callback(let callback) = self.widgetState {
                callback(assets)
            }            
            
        default:
            break
        }
    }

    init(navigationRouter: NavigationRouter){
        self.navigationRouter = navigationRouter
    }
    
    func start() {
        
        let vc = WidgetSettingsModuleBuilder(output: self).build()
        
        self.navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        }                
    }
}

// MARK: AssetsSearchModuleOutput

extension WidgetSettingsCoordinator: AssetsSearchModuleOutput {
    
    func assetsSearchSelectedAssets(_ assets: [DomainLayer.DTO.Asset]) {
        self.statePopover = .syncAssets(assets)
    }
}

// MARK: WidgetSettingsModuleOutput

extension WidgetSettingsCoordinator: WidgetSettingsModuleOutput {
    
    func widgetSettingsSyncAssets(current: [DomainLayer.DTO.Asset], callback: @escaping (([DomainLayer.DTO.Asset]) -> Void)) {
        
        let vc = AssetsSearchViewBuilder(output: self)
        .build(input: current)
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        
        self.widgetState = .callback(callback)
        
        self.navigationRouter.present(vc, animated: true) {
            
        }
    }
    
    func widgetSettingsChangeInterval(_ selected: WidgetSettings.DTO.Interval?, callback: @escaping (_ asset: WidgetSettings.DTO.Interval) -> Void) {
        
        let all = WidgetSettings.DTO.Interval.all
        
        let elements: [ActionSheet.DTO.Element] = all.map { .init(title: $0.title) }
        
        let selectedElement = elements.first(where: { $0.title == (selected?.title ?? "") })
        
        let data = ActionSheet.DTO.Data.init(title: "Update interval",
                                             elements: elements,
                                             selectedElement: selectedElement)
            
        let vc = ActionSheetViewBuilder { [weak self] (element) in
            guard let interval = all.first(where: { (interval) -> Bool in
                return interval.title == element.title
            }) else { return }
            callback(interval)
            self?.navigationRouter.dismiss(animated: true, completion: nil)
        }
        .build(input: data)
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
                        
        self.navigationRouter.present(vc, animated: true) {
            
        }
    }
    
    func widgetSettingsChangeStyle(_ selected: WidgetSettings.DTO.Style?, callback: @escaping (_ style: WidgetSettings.DTO.Style) -> Void) {
    
        let all = WidgetSettings.DTO.Style.all
        
        let elements: [ActionSheet.DTO.Element] = all.map { .init(title: $0.title) }
        
        let selectedElement = elements.first(where: { $0.title == (selected?.title ?? "") })
        
        let data = ActionSheet.DTO.Data.init(title: "Widget style",
                                             elements: elements,
                                             selectedElement: selectedElement)
        
        let vc = ActionSheetViewBuilder { [weak self] (element) in
            guard let style = all.first(where: { (style) -> Bool in
                return style.title == element.title
            }) else { return }
            callback(style)
            self?.navigationRouter.dismiss(animated: true, completion: nil)
        }
        .build(input: data)
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        
        self.navigationRouter.present(vc, animated: true) {
            
        }
    }
}

// TODO: Localization

private extension WidgetSettings.DTO.Interval {
    
    var title: String {
        switch self {
        case .m1:
            return "1 minute"
            
        case .m5:
            return "5 minute"
            
        case .m10:
            return "10 minute"
            
        case .manually:
            return "Update manually"
        }
    }
    
    static var all: [WidgetSettings.DTO.Interval] {
        return [.m1, .m5, .m10, .manually]
    }
}

private extension WidgetSettings.DTO.Style {
    
    var title: String {
        switch self {
        case .dark:
            return "Dark"
            
        case .classic:
            return "Classic"
        }
    }
    
    static var all: [WidgetSettings.DTO.Style] {
        return [.classic, .dark]
    }
}
