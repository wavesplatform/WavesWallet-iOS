//
//  RateApp.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

private enum Constants {
    static let appURL: String = "https://itunes.apple.com/us/app/waves-wallet/id1233158971?mt=8"
}

enum RateApp {

    static func show() {
        showItunes()
    }

    private static func showItunes() {
        guard let url = URL(string: Constants.appURL) else { return }
        UIApplication.shared.openURLAsync(url)
    }
}

