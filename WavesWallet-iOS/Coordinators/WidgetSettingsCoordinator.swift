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
    
    func widgetSettingsSyncAssets(_ current: [DomainLayer.DTO.Asset], minCountAssets: Int, maxCountAssets: Int, callback: @escaping (([DomainLayer.DTO.Asset]) -> Void)) {
        
        let vc = AssetsSearchViewBuilder(output: self)
            .build(input: .init(assets: current, minCountAssets: minCountAssets, maxCountAssets: maxCountAssets))
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        
        self.widgetState = .callback(callback)
        
        self.navigationRouter.present(vc, animated: true) {
            
        }
    }
    
    func widgetSettingsChangeInterval(_ selected: DomainLayer.DTO.Widget.Interval?, callback: @escaping (_ asset: DomainLayer.DTO.Widget.Interval) -> Void) {
        
        let all = DomainLayer.DTO.Widget.Interval.all
        
        let elements: [ActionSheet.DTO.Element] = all.map { .init(title: $0.title) }
        
        let selectedElement = elements.first(where: { $0.title == (selected?.title ?? "") })
        
        let data = ActionSheet.DTO.Data.init(title: Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.title,
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
    
    func widgetSettingsChangeStyle(_ selected: DomainLayer.DTO.Widget.Style?, callback: @escaping (_ style: DomainLayer.DTO.Widget.Style) -> Void) {
    
        let all = DomainLayer.DTO.Widget.Style.all
        
        let elements: [ActionSheet.DTO.Element] = all.map { .init(title: $0.title) }
        
        let selectedElement = elements.first(where: { $0.title == (selected?.title ?? "") })
        
        let data = ActionSheet.DTO.Data.init(title: Localizable.Waves.Widgetsettings.Actionsheet.Changestyle.title,
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

private extension DomainLayer.DTO.Widget.Interval {
    
    var title: String {
        switch self {
        case .m1:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.m1
            
        case .m5:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.m5
            
        case .m10:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.m10
            
        case .manually:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.manually
        }
    }
    
    static var all: [DomainLayer.DTO.Widget.Interval] {
        return [.m1, .m5, .m10, .manually]
    }
}

private extension DomainLayer.DTO.Widget.Style {
    
    var title: String {
        switch self {
        case .dark:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changestyle.Element.dark
            
        case .classic:
            return  Localizable.Waves.Widgetsettings.Actionsheet.Changestyle.Element.classic
        }
    }
    
    static var all: [DomainLayer.DTO.Widget.Style] {
        return [.classic, .dark]
    }
}
