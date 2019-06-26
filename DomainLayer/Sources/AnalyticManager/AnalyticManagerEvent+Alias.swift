//
//  Alias.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

//MARK: - Alias
public extension AnalyticManagerEvent {
    enum Alias: String {
        
        /* Нажата кнопка «Create a new alias» на экране профайла. */
        case createProfile = "Alias Create Profile"
        
        /* Нажата кнопка «Create a new alias» на экране визитки. */
        case aliasCreateVcard = "Alias Create Vcard"
    }
}
