//
//  AssetsRepositoryDAO.swift
//  DomainLayer
//
//  Created by rprokofev on 20.07.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol AssetsRepositoryDAO  {

    func assets(serverEnvironment: ServerEnvironment,
                ids: [String],
                accountAddress: String) -> Observable<[Asset]>
            
    func saveAssets(_ assets:[Asset],
                    by accountAddress: String) -> Observable<Bool>
    func saveAsset(_ asset: Asset,
                   by accountAddress: String) -> Observable<Bool>
}
