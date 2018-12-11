//
//  SpamCSV+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import CSV

fileprivate enum Constants {
    static let keyAddress: String = "scam"
}

enum SpamCVC {

    enum SpamError: Error {
        case invalid
    }

    static func scamAddressFrom(row: [String]) -> String? {

        if row.count == 1 {
            return row[0]
        }

        if row.count > 2 {
            return nil
        }

        let address = row[0]
        let type = row[1]

        if type.lowercased() != Constants.keyAddress, address.count == 0 {
            return nil
        }

        return address
    }

    static func addresses(from data: Data) throws -> [String] {
        guard let text = String(data: data, encoding: .utf8) else { throw SpamError.invalid }
        guard let csv: CSV = try? CSV(string: text, hasHeaderRow: false) else { throw SpamError.invalid }

        var addresses = [String]()
        while let row = csv.next() {
            guard let address = SpamCVC.scamAddressFrom(row: row) else { continue }
            addresses.append(address)
        }
        return addresses
    }
}
