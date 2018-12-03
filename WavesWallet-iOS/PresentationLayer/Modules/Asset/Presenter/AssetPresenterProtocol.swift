//
//  AssetViewPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AssetModuleOutput: AnyObject {

    func showSend(asset: DomainLayer.DTO.SmartAssetBalance)
    func showReceive(asset: DomainLayer.DTO.SmartAssetBalance)
    func showHistory(by assetId: String)
    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int)
    func showBurn(asset: DomainLayer.DTO.SmartAssetBalance, delegate: TokenBurnTransactionDelegate?)
}

protocol AssetModuleInput {

    var assets: [AssetTypes.DTO.Asset.Info] { get set }
    var currentAsset: AssetTypes.DTO.Asset.Info { get set }
}

protocol AssetPresenterProtocol {

    typealias Feedback = (Driver<AssetTypes.State>) -> Signal<AssetTypes.Event>

    var interactor: AssetInteractorProtocol! { get set }
    var moduleOutput: AssetModuleOutput? { get set }

    func system(feedbacks: [Feedback])
}
