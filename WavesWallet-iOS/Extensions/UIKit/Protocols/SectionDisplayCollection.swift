//
//  SectionDisplayCollection.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 15/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol SectionProtocol {
    associatedtype Row
    var rows: [Row] { get set }
}

protocol DataSourceProtocol {
    associatedtype Section: SectionProtocol
    var sections: [Section] { get set }
}

extension DataSourceProtocol {
    subscript(indexPath: IndexPath) -> Section.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
}

extension SectionProtocol {
    subscript(index: Int) -> Row {
        return rows[index]
    }
}

extension Array where Element: SectionProtocol {

    subscript(indexPath: IndexPath) -> Element.Row {
        return self[indexPath.section][indexPath.row]
    }
}
