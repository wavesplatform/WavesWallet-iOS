//
//  SweetLoggerConsole.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public final class SweetLoggerConsole: SweetLoggerProtocol {
    
    public var visibleLevels: [SweetLoggerLevel]
    
    public var isShortLog = true
    
    init(visibleLevels: [SweetLoggerLevel],
         isShortLog: Bool) {
        
        self.visibleLevels = visibleLevels
        self.isShortLog = isShortLog
    }
    
    public func send(message: @escaping @autoclosure () -> Any,
              level: SweetLoggerLevel,
              file: String,
              function: String,
              line: Int,
              context: Any?,
              type: Any.Type? = nil)
    {
        guard visibleLevels.contains(level) == true else { return }
        
        var nameClass = ""
        if let type = type {
            nameClass = nameType(type)
        }
        
        let message = "\(level.nameLevel) \(nameClass) 👉 \(message()) 👈"
        
        DispatchQueue.main.async {
            print(message)
            
            if self.isShortLog {
                return
            }
            let fileLast = String(file.split(separator: "/").last ?? "")
            print(fileLast)
            print(line)
            print(function)
        }
    }
}

private extension SweetLoggerLevel {
    
    var nameLevel: String {
        
        switch self {
        case .debug:
            return "🐞 Debug:"
        case .error:
            return "‼️ Error:"
        case .info:
            return "🦄 Info:"
        case .verbose:
            return "🌈 Verbose"
        case .warning:
            return "🎯 Warning:"
        case .network:
            return "🛰 Network:"
        }
    }
}
