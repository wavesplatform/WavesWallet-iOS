//
//  AssetsUseCaseProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

public protocol AssetsUseCaseProtocol {
    func assets(by ids: [String], accountAddress: String) -> Observable<[Asset]>
    func assetsSync(by ids: [String], accountAddress: String) -> SyncObservable<[Asset]>
}
