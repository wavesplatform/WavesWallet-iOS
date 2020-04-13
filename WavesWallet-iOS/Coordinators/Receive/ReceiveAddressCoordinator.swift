//
//  ReceiveAddressCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveAddressCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = .init()
    var parent: Coordinator?
    
    private let navigationRouter: NavigationRouter
    private let generateType: ReceiveGenerateAddress.DTO.GenerateType
    
    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
    }
           
    init(navigationRouter: NavigationRouter,
         generateType: ReceiveGenerateAddress.DTO.GenerateType) {
        
        self.navigationRouter = navigationRouter
        self.generateType = generateType
    }
    
    func start() {
                
        let vc = ReceiveAddressModuleBuilder(output: self)
            .build(input: generateType.viewModel)
        navigationRouter.pushViewController(vc, animated: true)
    }
}

// MARK: ReceiveAddressViewControllerModuleOutput

extension ReceiveAddressCoordinator: ReceiveAddressViewControllerModuleOutput {
    
    func receiveAddressDidTapShare(address: String) {
        let activityVC = UIActivityViewController(activityItems: [address], applicationActivities: [])
        navigationRouter.present(activityVC, animated: true, completion: nil)
    }
    
    func receiveAddressDidTapClose() {
        // TODO: Need refactor
        
        let maybeAssetVC = navigationRouter.navigationController.viewControllers.first {
            $0.classForCoder == AssetDetailViewController.classForCoder()
        }
        
        if let assetVc = maybeAssetVC {
            navigationRouter.navigationController.popToViewController(assetVc, animated: true)
        } else {
            navigationRouter.popToRootViewController(animated: true)
        }
    }
    
    func receiveAddressDidShowInfo() {
        
        guard let cryptoCurrency = self.generateType.cryptoCurrency else { return }
        let asset = cryptoCurrency.asset
        
        var elements: [TooltipTypes.DTO.Element] = .init()

        let titleGeneralTooltip = Localizable.Waves.Receiveaddress.Tootltip.General.title(asset.name)
        let descriptionGeneralTooltip = Localizable.Waves.Receiveaddress.Tootltip.General.subtitle(asset.displayName)
        
        elements.append(.init(title: titleGeneralTooltip,
                              description: descriptionGeneralTooltip))
        
        if cryptoCurrency.asset.isBTC {
                
            let titleTooltip = Localizable.Waves.Receiveaddress.Tootltip.Btc.title
            let descriptionTooltip = Localizable.Waves.Receiveaddress.Tootltip.Btc.subtitle
            
            elements.append(.init(title: titleTooltip,
                                  description: descriptionTooltip))
        }
        
        let title = Localizable.Waves.Receiveaddress.Tootltip.title
        let data = TooltipTypes.DTO.Data.init(title: title,
                                              elements: elements)
      
        let vc = TooltipModuleBuilder(output: self)
            .build(input: .init(data: data))
      
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
      
        self.navigationRouter.present(vc, animated: true, completion: nil)
    }
}

// MARK: TooltipViewControllerModulOutput
extension ReceiveAddressCoordinator: TooltipViewControllerModulOutput {
    
    func tooltipDidTapClose() {
        self.navigationRouter.dismiss(animated: true, completion: nil)
    }
}

// MARK: Mapping

private extension ReceiveGenerateAddress.DTO.GenerateType {
        
    var viewModel: ReceiveAddress.ViewModel.DisplayData {
     
        switch self {
        case .cryptoCurrency:
            return .init(address: self.addreses, hasShowInfo: true)
        case .invoice:
            return .init(address: self.addreses, hasShowInfo: false)
        }
    }
        
        
    var addreses: [ReceiveAddress.ViewModel.Address] {
        switch self {
        case .cryptoCurrency(let model):
        
            return model
                .addresses
                .map { ReceiveAddress.ViewModel.Address(assetName: model.asset.displayName,
                                                        address: $0.address,
                                                        addressTypeName: $0.name,
                                                        icon: model.asset.iconLogo) }
            
        case .invoice(let model):
            return [ReceiveAddress.ViewModel.Address(assetName: model.assetName,
                                                     address: model.address,
                                                     addressTypeName: "Invoice",
                                                     icon: model.icon)]
            
        }
    }
}

