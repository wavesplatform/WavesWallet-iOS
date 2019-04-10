//
//  SweetLoggerProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public enum SweetLoggerLevel {
    case error
    case debug
    case warning
    case verbose
    case info
    case network
}

public protocol SweetLoggerProtocol {
    
    func send(message: @escaping @autoclosure () -> Any,
              level: SweetLoggerLevel,
              file: String,
              function: String,
              line: Int,
              context: Any?,
              type: Any.Type?)
    
    var visibleLevels: [SweetLoggerLevel] { get }
}
