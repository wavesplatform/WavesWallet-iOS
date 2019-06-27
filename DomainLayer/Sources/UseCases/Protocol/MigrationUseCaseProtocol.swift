//
//  MigrationUseCaseProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol MigrationUseCaseProtocol {
    func migration() -> Observable<Void>
}
