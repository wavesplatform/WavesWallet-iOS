//
//  TooltipTypes.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

enum TooltipTypes {
    enum ViewModel {}
    enum DTO {}
}

extension TooltipTypes.DTO {
    
    struct Element {
        let title: String
        let description: String
    }
    
    struct Data {
        let title: String
        let elements: [Element]
    }
}

extension TooltipTypes.ViewModel {
        
    enum Row {
        case element(TooltipInfoCell.Model)
        case separator
        case button
    }
}
