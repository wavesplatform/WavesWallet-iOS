//
//  SpamAssetsService.swift
//  DomainLayer
//
//  Created by rprokofev on 27.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol SpamAssetsService {
    func spamAssets(by url: URL) -> Observable<[String]>
}
