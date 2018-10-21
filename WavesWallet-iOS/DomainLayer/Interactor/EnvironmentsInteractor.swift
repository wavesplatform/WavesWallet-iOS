//
//  EnvironmentsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


protocol EnvironmentRepositoryProtocol {
    func environment() -> Observable<Environment>
}


