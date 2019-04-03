//
//  String+Escaped.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
