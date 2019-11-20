//
//  RateApp.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import WavesSDK

enum RateApp {

    static func show() {
        showItunes()
    }

    private static func showItunes() {
        UIApplication.shared.openURLAsync(WavesSDKConstants.appstoreURL)
    }
}

