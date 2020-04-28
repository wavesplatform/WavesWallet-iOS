//
//  WEOAuthService.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
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

public protocol WEOAuthService {
    func oauthToken(serverEnvironment: ServerEnvironment,
                    signedWallet: DomainLayer.DTO.SignedWallet) -> Observable<WEOAuthTokenDTO>
}
