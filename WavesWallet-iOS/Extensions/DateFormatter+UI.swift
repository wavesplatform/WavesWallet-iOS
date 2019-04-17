//
//  DateFormatter+UI.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/04/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DateFormatter {

    static func uiSharedFormatter(key: String) -> DateFormatter {
        let formatter = Thread
            .threadSharedObject(key: key,
                                create: { return DateFormatter() })

        formatter.locale = Localizable.current.locale
        return formatter
    }
}

