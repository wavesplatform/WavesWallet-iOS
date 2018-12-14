//
//  String+URL.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension String {

    var isValidUrl: Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
}
