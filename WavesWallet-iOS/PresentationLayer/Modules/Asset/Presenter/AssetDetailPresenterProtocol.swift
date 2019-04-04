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

protocol AssetDetailModuleOutput: AnyObject {

    func showSend(asset: DomainLayer.DTO.SmartAssetBalance)
    func showReceive(asset: DomainLayer.DTO.SmartAssetBalance)
    func showHistory(by assetId: String)
    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int)
    func showBurn(asset: DomainLayer.DTO.SmartAssetBalance, delegate: TokenBurnTransactionDelegate?)
}

protocol AssetDetailModuleInput {

    var assets: [AssetDetailTypes.DTO.Asset.Info] { get set }
    var currentAsset: AssetDetailTypes.DTO.Asset.Info { get set }
}

protocol AssetDetailPresenterProtocol {

    typealias Feedback = (Driver<AssetDetailTypes.State>) -> Signal<AssetDetailTypes.Event>

    var interactor: AssetDetailInteractorProtocol! { get set }
    var moduleOutput: AssetDetailModuleOutput? { get set }

    func system(feedbacks: [Feedback])
}
