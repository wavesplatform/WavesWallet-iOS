//
//  DateFormatter+Once.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DateFormatter {

    private enum Constants {
        static let DateFormatterKey = "waves.dateFormatter"
    }

    static var sharedFormatter: DateFormatter {
        return Thread
            .threadSharedObject(key: Constants.DateFormatterKey,
                                create: { return DateFormatter() })
    }
}
