//
//  DataService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum API {}

extension API {
    enum Service {}
    enum DTO {}
    enum Query {}
}

protocol ApiTargetType: BaseTargetType {}

extension ApiTargetType {
    private var apiVersion: String {
        return "/v0"
    }

    private var apiUrl: String {
        return Environments.current.servers.dataUrl.relativeString
    }

    var baseURL: URL { return URL(string: "\(apiUrl)\(apiVersion)")! }
}
