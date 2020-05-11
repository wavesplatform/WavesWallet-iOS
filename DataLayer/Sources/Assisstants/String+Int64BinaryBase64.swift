//
//  String+Int4Binary.swift
//  DataLayer
//
//  Created by rprokofev on 13.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKCrypto

extension String {
    
    // String decode from base64 to Int64
    func decodeInt64FromBase64() -> Int64 {
        
        guard !self.isEmpty else { return 0 }
        guard let bytes = WavesCrypto.shared.base64decode(input: self) else { return 0 }
            
        var value: Int64 = 0
        
        bytes.forEach { byte in
            value = value << 8
            value = value | Int64(byte)
        }

        return value
    }
}


extension Data {
    
    func decodeInt64() -> Int64 {
        
        guard !self.isEmpty else { return 0 }
                    
        var value: Int64 = 0
                
        self.forEach { byte in
            value = value << 8
            value = value | Int64(byte)
        }

        return value
    }
    
    //TODO: С сети может придти больше чем int64, как с этим быть сейчас хз
    // Я пока не знаю как бинарник перевести в Decimal
    func decodeDecimal() -> Decimal {
                
        guard !self.isEmpty else { return 0 }
        return Decimal(self.decodeInt64())
    }
}
