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

final class WidgetSettingsCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    weak var parent: Coordinator?
    
    private var navigationRouter: NavigationRouter
    
    private let disposeBag: DisposeBag = DisposeBag()
    
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

extension WidgetSettingsCoordinator: WidgetSettingsModuleOutput {
    
    func widgetSettingsAddAsset(callback: @escaping (_ asset: DomainLayer.DTO.Asset) -> Void) {
    
    }
    
    func widgetSettingsChangeInterval(callback: @escaping (_ asset: WidgetSettings.DTO.Interval) -> Void) {
    
    }
    
    func widgetSettingsChangeStyle(callback: @escaping (_ asset: WidgetSettings.DTO.Style) -> Void) {
    
    }
}

