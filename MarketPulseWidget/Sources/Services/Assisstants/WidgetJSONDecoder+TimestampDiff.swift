
//
//  JSONDecoder+Date.swift
//  Alamofire
//
//  Created by rprokofev on 30/04/2019.
//

import Foundation

//TODO - Duplicate file from WavesSDK
//to fix, we need update extension to public

extension JSONDecoder {
    
    static func decoderBySyncingTimestamp(_ timestampServerDiff: Int64) -> JSONDecoder {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            return Date(timestampDecoder: decoder, timestampDiff: timestampServerDiff)
        }
        
        return decoder
    }
    
    static func isoDecoderBySyncingTimestamp(_ timestampServerDiff: Int64) -> JSONDecoder {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            return Date(isoDecoder: decoder, timestampDiff: timestampServerDiff)
        }
        
        return decoder
    }    
}

