//
//  EnterStartTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

enum EnterStartTypes {
    
    enum Block {
        case blockchain
        case wallet
        case dex
    }
    
}

extension EnterStartTypes.Block {
    
    var image: UIImage {
        switch self {
        case .blockchain:
            return Images.userimgBlockchain80.image
        case .wallet:
            return Images.userimgWallet80.image
        case .dex:
            return Images.userimgDex80.image
        }
    }
    
    var title: String {
        switch self {
        case .blockchain:
            return Localizable.Waves.Enter.Block.Blockchain.title
        case .wallet:
            return Localizable.Waves.Enter.Block.Wallet.title
        case .dex:
            return Localizable.Waves.Enter.Block.Exchange.title
        }
    }
    
    var text: String {
        switch self {
        case .blockchain:
            return Localizable.Waves.Enter.Block.Blockchain.text
        case .wallet:
            return Localizable.Waves.Enter.Block.Wallet.text
        case .dex:
            return Localizable.Waves.Enter.Block.Exchange.text
        }
    }
}
