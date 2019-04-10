//
//  DateFormatter+ISO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DateFormatter {

    private enum Constants {
        static let key: String = "dateFormatter.iso"
    }

    static func iso() -> DateFormatter {

        let dateFormatter = Thread
            .threadSharedObject(key: Constants.key,
                                create: { return DateFormatter() })
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter
    }
}
