//
//  DateFormatter+ISO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DateFormatter {

    static func iso() -> DateFormatter {
        let dateFormatter = DateFormatter.sharedFormatter
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter
    }
}
