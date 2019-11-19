//
//  ServerMaintenanceRepository.swift
//  DataLayer
//
//  Created by rprokofev on 19.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

public final class ServerMaintenanceRepository: ServerMaintenanceRepositoryProtocol {
    
    public func isEnabledMaintenance() -> Observable<Bool> {
        return Observable.just(false)
    }
}

