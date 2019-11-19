//
//  ActionSheet.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 02.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum ActionSheet {
    enum DTO {}
}

extension ActionSheet.DTO {
    struct Element {
        let title: String
    }
    
    struct Data {
        let title: String
        let elements: [Element]
        let selectedElement: Element?
        var blockedElements: [Element] = []
    }
}
