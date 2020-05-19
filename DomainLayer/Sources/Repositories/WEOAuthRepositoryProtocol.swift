//
//  WavesExchangeAuthProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public struct WEOAuthTokenDTO {
    public let accessToken: String

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public protocol WEOAuthRepositoryProtocol {
    func oauthToken(signedWallet: SignedWallet) -> Observable<WEOAuthTokenDTO>
}


