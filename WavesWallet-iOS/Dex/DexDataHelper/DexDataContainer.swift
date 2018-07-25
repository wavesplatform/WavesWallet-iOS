//
//  DexDataContainer.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import SwiftyJSON


enum DexDataState {
    case isLoading
    case normal
}

protocol DexDataContainerDelegate: class {
    func dexDataContainerDidUpdateModels(_ dataContainer: DexDataContainer, models: [DexListModel])
}

final class DexDataContainer {
    
    var delegate: DexDataContainerDelegate?
    
    private var items: [DexListModel] = []
    
    private(set) var state = DexDataState.isLoading
    
    var models: [DexListModel] {
        return items
    }
    
    //MARK: - TableData
    
    func modelForIndexPath(_ indexPath: IndexPath) -> DexListModel {
        return models[indexPath.row]
    }
    
    var countSections: Int {
        if state == .isLoading {
            return 1
        }
        return 2
    }
    
    var numberOfRows: Int {
        if state == .isLoading {
            return 4
        }
        return models.count
    }
}


//MARK: - Test Data

extension DexDataContainer {
    
    func simulateDataFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.initTestData()
            self.state = .normal
            self.delegate?.dexDataContainerDidUpdateModels(self, models: self.models)
        }
    }
    
    private func initTestData() {
        for _ in 0..<10 {
            items.append(DexListModel(json: JSON()))
        }
    }
    
}
