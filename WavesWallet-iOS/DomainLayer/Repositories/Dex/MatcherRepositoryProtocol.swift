//
//  MatcherRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol MatcherRepositoryProtocol {
    
    func matcherPublicKey(accountAddress: String) -> Observable<PublicKeyAccount>
}
