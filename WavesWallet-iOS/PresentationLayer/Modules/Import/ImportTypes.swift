//
//  ImportTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension

enum ImportTypes {
    enum DTO { }
    
}

extension ImportTypes.DTO {
    struct Account {
        let privateKey: PrivateKeyAccount
        let password: String
        let name: String
    }
}
