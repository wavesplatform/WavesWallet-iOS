//
//  UIApplication+OpenURL.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIApplication {
    func openURLAsync(_ url: URL) {
        DispatchQueue.main.async {
            self.open(url, options: .init(), completionHandler: nil)
        }
    }
}
