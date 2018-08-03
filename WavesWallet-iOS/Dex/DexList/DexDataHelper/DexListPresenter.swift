//
//  DexDataContainer.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexListPresenterDelegate: AnyObject {
    func dexListPresenter(listPresenter: DexListPresenter, didUpdateModels models: [DexList.DTO.DexListModel])
}

final class DexListPresenter {

    weak var delegate: DexListPresenterDelegate?
    
    private let interactor : DexListInteractorProtocol = DexListInteractorMock()
    private(set) var state = DexList.State.isLoading
    private(set) var models: [DexList.DTO.DexListModel] = []
    private let bag = DisposeBag()

    private var hasSetup = false
    
    //MARK: - TableData
    
    func modelForIndexPath(_ indexPath: IndexPath) -> DexList.DTO.DexListModel {
        return models[indexPath.row]
    }
 
    func numberOfRows(_ section: Int) -> Int {
        if state == .isLoading {
            if section == DexListViewController.Section.header.rawValue {
                return 0
            }
            return 4
        }
        
        if section == DexListViewController.Section.header.rawValue {
            return 1
        }
        return models.count
    }
 
    
    func setupObservable() {
        if hasSetup {
            return
        }
        hasSetup = true
        simulateDataFromServer()
    }
}


//MARK: - Test Data

extension DexListPresenter {
    
    private func simulateDataFromServer() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.interactor.dexPairs().subscribe(onNext: { (result) in
                self.state = .normal
                self.models = result
                self.delegate?.dexListPresenter(listPresenter: self, didUpdateModels: self.models)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.bag)
        }
    }
  
    
}
