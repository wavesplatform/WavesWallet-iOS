//
//  SweetLogger.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension SweetLogger {

    static func error(_ message: @escaping  @autoclosure () -> Any,
               _ file: String = #file,
               _ function: String = #function,
               _ line: Int = #line,
               _ context: Any? = nil,
               type: Any.Type? = nil)
    {
        SweetLogger.current.send(message: message, level: .error, file: file, function: function, line: line, context: context, type: type)
    }

    static func warning(_ message: @escaping @autoclosure () -> Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 _ line: Int = #line,
                 _ context: Any? = nil,
                 type: Any.Type? = nil)
    {
        SweetLogger.current.send(message: message, level: .warning, file: file, function: function, line: line, context: context)
    }

    static func debug(_ message: @escaping   @autoclosure () -> Any,
               _ file: String = #file,
               _ function: String = #function,
               _ line: Int = #line,
               _ context: Any? = nil,
               type: Any.Type? = nil)
    {
        SweetLogger.current.send(message: message, level: .debug, file: file, function: function, line: line, context: context, type: type)
    }

    static func verbose(_ message: @escaping  @autoclosure () -> Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 _ line: Int = #line,
                 _ context: Any? = nil,
                 type: Any.Type? = nil)
    {
        SweetLogger.current.send(message: message, level: .verbose, file: file, function: function, line: line, context: context, type: type)
    }

    static func info(_ message: @escaping  @autoclosure () -> Any,
              _ file: String = #file,
              _ function: String = #function,
              _ line: Int = #line,
              _ context: Any? = nil,
              type: Any.Type? = nil)
    {
        SweetLogger.current.send(message: message, level: .info, file: file, function: function, line: line, context: context, type: type)
    }

    static func network(_ message: @escaping  @autoclosure () -> Any,
                 _ file: String = #file,
                 _ function: String = #function,
                 _ line: Int = #line,
                 _ context: Any? = nil,
                 type: Any.Type? = nil)
    {
        SweetLogger.current.send(message: message, level: .network, file: file, function: function, line: line, context: context, type: type)
    }
}

final class SweetLogger: SweetLoggerProtocol {
    
    static let current: SweetLogger = SweetLogger()
    
    var visibleLevels: [SweetLoggerLevel] = []
    var plugins: [SweetLoggerProtocol] = []
    
    func send(message: @escaping @autoclosure () -> Any,
              level: SweetLoggerLevel,
              file: String,
              function: String,
              line: Int,
              context: Any?,
              type: Any.Type? = nil)
    {
        guard visibleLevels.contains(level) == true else { return }
        
        for plugin in self.plugins {
            
            guard plugin.visibleLevels.contains(level) == true else { continue }
            plugin.send(message: message,
                        level: level,
                        file: file,
                        function: function,
                        line: line,
                        context: context,
                        type: type)
        }
        
    }
}
