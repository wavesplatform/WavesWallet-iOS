//
//  SectionDisplayCollection.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 15/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

public protocol SectionProtocol {
    associatedtype Row
    var rows: [Row] { get set }
}

public protocol DataSourceProtocol {
    associatedtype Section: SectionProtocol
    var sections: [Section] { get set }
}

public extension DataSourceProtocol {
    subscript(indexPath: IndexPath) -> Section.Row {
        get {
            return sections[indexPath.section].rows[indexPath.row]
        }
        
        set {
            sections[indexPath.section].rows[indexPath.row] = newValue
        }
    }
    
    subscript(section: Int) -> Section {
        get {
            return sections[section]
        }
        
        set {
            sections[section] = newValue
        }
    }
}

public extension SectionProtocol {
    subscript(index: Int) -> Row {
        get {
            return rows[index]
        }
        set {
            rows[index] = newValue
        }
    }
}

public extension Array where Element: SectionProtocol {

    subscript(indexPath: IndexPath) -> Element.Row {
        return self[indexPath.section][indexPath.row]
    }
}
