//
//  SpamAssetsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 25.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public typealias SpamAssetId = String

public protocol SpamAssetsRepositoryProtocol {
    
    func spamAssets(accountAddress: String) -> Observable<[SpamAssetId]>
}
