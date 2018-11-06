//
//  AssetModuleBuild.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct AssetModuleBuilder: ModuleBuilderOutput {

    struct Input: AssetModuleInput {
        var assets: [AssetTypes.DTO.Asset.Info]
        var currentAsset: AssetTypes.DTO.Asset.Info
    }

    var output: AssetModuleOutput

    func build(input: AssetModuleBuilder.Input) -> UIViewController {

        let presenter = AssetPresenter(input: input)
        let vc = StoryboardScene.Asset.assetViewController.instantiate()

        presenter.interactor = AssetInteractor()
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
