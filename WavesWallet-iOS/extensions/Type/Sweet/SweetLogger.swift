//
//  SweetLogger.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

func warning(_ message: @escaping @autoclosure () -> Any,
             _ file: String = #file,
             _ function: String = #function,
             _ line: Int = #line,
             _ context: Any? = nil,
            type: Any.Type? = nil)
{
    SweetLogger.current.send(message: message, level: .warning, file: file, function: function, line: line, context: context)
}

func error(_ message: @escaping  @autoclosure () -> Any,
             _ file: String = #file,
             _ function: String = #function,
             _ line: Int = #line,
             _ context: Any? = nil,
            type: Any.Type? = nil)
{
    SweetLogger.current.send(message: message, level: .error, file: file, function: function, line: line, context: context, type: type)
}

func debug(_ message: @escaping   @autoclosure () -> Any,
           _ file: String = #file,
           _ function: String = #function,
           _ line: Int = #line,
           _ context: Any? = nil,
           type: Any.Type? = nil)
{
    SweetLogger.current.send(message: message, level: .debug, file: file, function: function, line: line, context: context, type: type)
}

func verbose(_ message: @escaping  @autoclosure () -> Any,
           _ file: String = #file,
           _ function: String = #function,
           _ line: Int = #line,
           _ context: Any? = nil,
           type: Any.Type? = nil)
{
    SweetLogger.current.send(message: message, level: .verbose, file: file, function: function, line: line, context: context, type: type)
}

func info(_ message: @escaping  @autoclosure () -> Any,
             _ file: String = #file,
             _ function: String = #function,
             _ line: Int = #line,
             _ context: Any? = nil,
             type: Any.Type? = nil)
{
    SweetLogger.current.send(message: message, level: .info, file: file, function: function, line: line, context: context, type: type)
}

func network(_ message: @escaping  @autoclosure () -> Any,
          _ file: String = #file,
          _ function: String = #function,
          _ line: Int = #line,
          _ context: Any? = nil,
          type: Any.Type? = nil)
{
    SweetLogger.current.send(message: message, level: .network, file: file, function: function, line: line, context: context, type: type)
}

enum SweetLoggerLevel {
    case error
    case debug
    case warning
    case verbose
    case info
    case network
}

protocol SweetLoggerProtocol {

    func send(message: @escaping @autoclosure () -> Any,
               level: SweetLoggerLevel,
               file: String,
               function: String,
               line: Int,
               context: Any?,
               type: Any.Type?)
}

final class SweetLogger: SweetLoggerProtocol {

    static let current: SweetLogger = SweetLogger()

    var visibleLevels: [SweetLoggerLevel] = []
    var isShortLog = true

    func send(message: @escaping @autoclosure () -> Any,
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
        DispatchQueue.main.async {
            print("\(self.nameLevel(level)) \(nameClass) 👉 \(message()) 👈")

            if self.isShortLog {
                return
            }
            let fileLast = String(file.split(separator: "/").last)
            print(fileLast)
            print(line)
            print(function)
        }
    }

    private  func nameLevel(_ level: SweetLoggerLevel) -> String {
        switch level {
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
