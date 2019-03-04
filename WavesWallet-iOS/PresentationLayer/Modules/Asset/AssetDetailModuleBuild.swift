//
//  AssetModuleBuild.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct AssetDetailModuleBuilder: ModuleBuilderOutput {

    struct Input: AssetDetailModuleInput {
        var assets: [AssetDetailTypes.DTO.Asset.Info]
        var currentAsset: AssetDetailTypes.DTO.Asset.Info
    }

    var output: AssetDetailModuleOutput

    func build(input: AssetDetailModuleBuilder.Input) -> UIViewController {

        let presenter = AssetDetailPresenter(input: input)
        let vc = StoryboardScene.Asset.assetViewController.instantiate()

        presenter.interactor = AssetDetailInteractor()
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
