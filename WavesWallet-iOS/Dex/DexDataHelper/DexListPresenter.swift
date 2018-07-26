//
//  DexDataContainer.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift


enum DexDataState {
    case isLoading
    case normal
}

protocol DexListPresenterDelegate: class {
    func dexListPresenter(listPresenter: DexListPresenter, didUpdateModels models: [DexListModel])
}

final class DexListPresenter: NSObject {
    
    var delegate: DexListPresenterDelegate?

    private(set) var state = DexDataState.isLoading
    private let interactor = DexInteractor()
    private var items: [DexListModel] = []
    private var tableView: UITableView!
    private var numbOfRows : Int = 0
    
    var models: [DexListModel] {
        return items
    }
    
    private let bag = DisposeBag()

    func setupTable(_ tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        
        interactor.dexPairs().subscribe(onNext: { (result) in
            self.numbOfRows = result.count
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
    }
    
    func numberOfRouw
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

//MARK: - UITableViewDataSource
extension DexListPresenter: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if state == .isLoading {
            let cell = tableView.dequeueCell() as DexListSkeletonCell
            cell.slide(to: .right)
            return cell
        }
        
        let cell: DexListCell = tableView.dequeueCell()
        cell.setupCell(modelForIndexPath(indexPath))
        return cell
    }

}

//MARK: - Test Data

extension DexListPresenter {
    
    func simulateDataFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.initTestData()
            self.state = .normal
            self.tableView.reloadData()
            self.delegate?.dexListPresenter(listPresenter: self, didUpdateModels: self.models)
        }
    }
    
    private func initTestData() {
        for _ in 0..<10 {
            items.append(DexListModel(json: JSON()))
        }
    }
    
}
