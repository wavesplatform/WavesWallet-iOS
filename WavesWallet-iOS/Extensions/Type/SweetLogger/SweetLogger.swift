//
//  SweetLogger.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Sentry

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

    var visibleLevels: [SweetLoggerLevel] { get }
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

final class SweetLoggerSentry: SweetLoggerProtocol {

    var visibleLevels: [SweetLoggerLevel] = []

    init(visibleLevels: [SweetLoggerLevel]) {

        self.visibleLevels = visibleLevels

        if let path = Bundle.main.path(forResource: "Sentry.io-Info", ofType: "plist"),
            let dsn = NSDictionary(contentsOfFile: path)?["DSN_URL"] as? String {

            do {
                Client.shared = try Client(dsn: dsn)
                try Client.shared?.startCrashHandler()
            } catch let error {
                print("SweetLogger :( \(error)")
            }
        }

        Client.shared?.enableAutomaticBreadcrumbTracking()
    }

    func send(message: @escaping @autoclosure () -> Any,
              level: SweetLoggerLevel,
              file: String,
              function: String,
              line: Int,
              context: Any?,
              type: Any.Type? = nil)
    {
        guard visibleLevels.contains(level) == true else { return }

        let event = Sentry.Event(level: level.sentrySeverity)
        event.message = "\(message())"
        Client.shared?.send(event: event, completion: nil)
    }

}

private extension SweetLoggerLevel {

    var sentrySeverity: SentrySeverity {
        switch self {
        case .debug:
            return SentrySeverity.debug

        case .error:
            return SentrySeverity.error

        case .warning:
            return SentrySeverity.info

        case .network:
            return SentrySeverity.info

        case .info:
            return SentrySeverity.info

        case .verbose:
            return SentrySeverity.info

        }
    }

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

final class SweetLoggerConsole: SweetLoggerProtocol {

    var visibleLevels: [SweetLoggerLevel]

    var isShortLog = true

    init(visibleLevels: [SweetLoggerLevel],
         isShortLog: Bool) {

        self.visibleLevels = visibleLevels
        self.isShortLog = isShortLog
    }

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
