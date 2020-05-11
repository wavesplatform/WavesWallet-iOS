//
//  DevelopmentConfigsService.swift
//  DomainLayer
//
//  Created by rprokofev on 29.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol DevelopmentConfigsRepositoryService {

    func isEnabledMaintenance() -> Observable<Bool>
    
    func developmentConfigs() -> Observable<DevelopmentConfigs>
}
