//
//  StorageFactory.swift
//  DataLayer
//
//  Created by rprokofev on 12.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

public final class DaoFactoryImp: DaoFactory {

    public init() {}
    
    public private(set) lazy var serverTimestampDiffDao: ServerTimestampDiffDao = {
        return ServerTimestampDiffDaoImp()
    }()
}
