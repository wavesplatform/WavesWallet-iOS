//
//  GrpcClient.swift
//  DataLayer
//
//  Created by rprokofev on 11.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import GRPC
import NIOHPACK
import NIOHTTP1
import NIOHTTP2
import SwiftProtobuf
import NIO

func grpcClient<Client: GRPCClient>(address: String,
                                    eventLoopGroup: EventLoopGroup,
                                    oAToken: String) -> Client {
    var headers = HPACKHeaders()
    headers.add(name: "Authorization",
                value: "Bearer \(oAToken)")

    let callOptions = CallOptions(customMetadata: headers)
    
    let tls = ClientConnection.Configuration.TLS()
    
    let configuration = ClientConnection.Configuration(target: .hostAndPort(address, 443),
                                                       eventLoopGroup: eventLoopGroup,
                                                       tls: tls)

    let connect = ClientConnection(configuration: configuration)

    return Client(channel: connect, defaultCallOptions: callOptions)
}
