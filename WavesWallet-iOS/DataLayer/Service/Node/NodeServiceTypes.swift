//
//  NodeTargetType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Foundation
import Result
import Moya

enum Node {}

extension Node {
    enum DTO {}
    enum Service {}
}

protocol NodeTargetType: BaseTargetType {}

extension NodeTargetType {
    var baseURL: URL { return environment.servers.nodeUrl }    
}


extension MoyaProvider {
    final class func nodeMoyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(callbackQueue: nil,
                            plugins: [SweetNetworkLoggerPlugin(verbose: true), NodePlugin()])
    }
}

private struct NodeHeaders: Encodable, Decodable, TSUD {

    var cflb: String?
    var awsalb: String?

    private static let key: String = "com.waves.plugin.node"

    static var defaultValue: NodeHeaders {
        return NodeHeaders(cflb: nil, awsalb: nil)
    }

    static var stringKey: String {
        return NodeHeaders.key
    }
}

private enum Constants {
    static let cflbKey = "__cflb"
    static let awsalbKey = "AWSALB"
}

struct NodePlugin: PluginType {

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {

        if let url = request.url {
            let cookies = HTTPCookieStorage.shared.cookies(for: url)
            SweetLogger.network(cookies ?? [])
        }
        return request
    }

    func willSend(_ request: RequestType, target: TargetType) {}

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {

        if let response = result.value?.response,
            let allHeaderFields = response.allHeaderFields as? [String : String],
            let url = response.url {

            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
            var cflb: String? = nil
            var awsalb: String? = nil

            for cookie in cookies {
                if cookie.name == Constants.cflbKey {
                    cflb = cookie.value
                }

                if cookie.name == Constants.awsalbKey {
                    awsalb = cookie.value
                }
            }

            HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)

            NodeHeaders.set(NodeHeaders(cflb: cflb, awsalb: awsalb))
        }
    }

    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        return result
    }
}
