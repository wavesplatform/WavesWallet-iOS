//
//  StringExtension.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 03/05/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

extension String {
    
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}
