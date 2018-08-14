//
//  SectionDisplayCollection.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 15/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol SectionCollection {
    associatedtype Row
    var rows: [Row] { get set }
}

protocol StateDisplayCollection {
    associatedtype Section: SectionCollection
    var sections: [Section] { get set }
}

extension StateDisplayCollection {
    subscript(indexPath: IndexPath) -> Section.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
}

extension SectionCollection {
    subscript(index: Int) -> Row {
        return rows[index]
    }
}
