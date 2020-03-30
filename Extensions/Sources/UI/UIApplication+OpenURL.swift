//
//  UIApplication+OpenURL.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public extension UIApplication {
    func openURLAsync(_ url: URL) {
        DispatchQueue.main.async {
            self.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(.init()), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any])
    -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
