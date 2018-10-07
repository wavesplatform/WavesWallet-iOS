//
//  ReceiveGenerateAddressModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveGenerateAddressModuleBuilder: ModuleBuilder {

    func build(input: ReceiveGenerate.DTO.GenerateType) -> UIViewController {
        
        let interactor: ReceiveGenerateInteractorProtocol = ReceiveGenerateInteractorMock()
        
        var presenter: ReceiveGeneratePresenterProtocol = ReceiveGeneratePresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Receive.receiveGenerateAddressViewController.instantiate()
        vc.input = input
        vc.presenter = presenter
        
        return vc
    }
}
