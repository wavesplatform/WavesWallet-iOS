//
//  SweetNetworki.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Result
import Moya


public final class SweetNetworkLoggerPlugin: PluginType {
    fileprivate let loggerId = "Network"
    fileprivate let dateFormatString = "dd/MM/yyyy HH:mm:ss"
    fileprivate let dateFormatter = DateFormatter()

    fileprivate var outputs: [String: [String]] = .init()

    /// A Boolean value determing whether response body data should be logged.
    public let isVerbose: Bool
    public let cURL: Bool = false
    public let isResponse: Bool = false

    public init(verbose: Bool = false) {
        self.isVerbose = verbose
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        
        if let request = request as? CustomDebugStringConvertible {
            outputItems([request.debugDescription, "\n"], target: target)
        } else {
            outputItems(logNetworkRequest(request.request as URLRequest?), target: target)
        }
    }

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {


        let key = target.key

        var isError: Bool = false

        if case .success(let response) = result {
            isError = response.statusCode > 299
            outputItems(logNetworkResponse(response.response,
                                           data: response.data,
                                           target: target),
                        target: target)
        } else if case .failure(let error) = result {
            isError = true
            outputItems(logNetworkError(error, target: target), target: target, isError: true)
        }

        if isError {
            outputsPrint(target: target)
        } else {
            outputs.removeValue(forKey: key)
        }
    }

    fileprivate func outputItems(_ items: [String], target: TargetType, isError: Bool = false) {

        let key = target.key

        if var errors = outputs[target.key] {
            errors.append(contentsOf: items)
            outputs[key] = errors
        } else {
            outputs[key] = items
        }
    }

    fileprivate func outputsPrint(target: TargetType) {

        let key = target.key

        if let outputs = outputs[key] {

            let message = "\(loggerId): \(date) \(target.baseURL.absoluteString) \n \(outputs.joined(separator: "\n"))"
            SweetLogger.error(message)
        }

        outputs.removeValue(forKey: key)
    }
}

private extension SweetNetworkLoggerPlugin {

    var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }

    func format(_ loggerId: String, date: String, identifier: String, message: String) -> String {
        return "\(identifier): \(message)"
    }

    func logNetworkRequest(_ request: URLRequest?) -> [String] {

        var output = [String]()

        output += [format(loggerId, date: date, identifier: "Request", message: request?.description ?? "(invalid request)")]

        if let headers = request?.allHTTPHeaderFields {
            output += [format(loggerId, date: date, identifier: "Request Headers", message: headers.description)]
        }

        if let bodyStream = request?.httpBodyStream {
            output += [format(loggerId, date: date, identifier: "Request Body Stream", message: bodyStream.description)]
        }

        if let httpMethod = request?.httpMethod {
            output += [format(loggerId, date: date, identifier: "HTTP Request Method", message: httpMethod)]
        }

        if let body = request?.httpBody, let stringOutput = String(data: body, encoding: .utf8), isVerbose {
            output += [format(loggerId, date: date, identifier: "Request Body", message: stringOutput)]
        }

        return output
    }

    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
            return [format(loggerId, date: date, identifier: "Response", message: "Received empty network response for \(target).")]
        }

        var output = [String]()

        output += [format(loggerId, date: date, identifier: "Response", message: response.description)]

        if let data = data, let stringData = String(data: data, encoding: String.Encoding.utf8), isVerbose {
            output += [stringData]
        }

        return output
    }

    func logNetworkError(_ error: MoyaError, target: TargetType) -> [String] {

        var output = [String]()

        if let errorDescription = error.errorDescription {
            output += [format(loggerId, date: date, identifier: "Description", message: errorDescription)]
        }

        if let responce = error.response {
            output += [format(loggerId, date: date, identifier: "Status Code", message: "\(responce.statusCode)")]

            if let responce = String(data: responce.data, encoding: String.Encoding.utf8) {
                output += [format(loggerId, date: date, identifier: "Responce", message: responce)]
            }
        }

        return output
    }
}

extension TargetType {
    var key: String {
        var output = [String]()
        output += [self.baseURL.absoluteString]
        output += ["\(self.headers.hashValue)"]
        output += [self.method.rawValue]
        output += [self.path]
        output += ["\(self.sampleData.hashValue)"]
        return output.joined(separator: "")
    }
}
