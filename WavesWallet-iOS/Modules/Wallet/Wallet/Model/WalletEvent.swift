//
//  WalletEvent.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//
import DomainLayer
import Extensions
import Foundation
import RxCocoa
import UIKit
import WavesSDKExtensions

enum WalletEvent {
    case setAssets([DomainLayer.DTO.SmartAssetBalance])
    case handlerError(Error)
    case refresh
    case viewDidAppear
    case viewDidDisappear
    case tapSection(Int)
    case changeDisplay(WalletDisplayState.Kind)
    case isHasAppUpdate(Bool)
}
