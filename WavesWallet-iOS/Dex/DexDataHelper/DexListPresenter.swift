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

protocol DexListPresenterDelegate: class {
    func dexListPresenter(listPresenter: DexListPresenter, didUpdateModels models: [DexTypes.DTO.DexListModel])
}

final class DexListPresenter {
    
    var delegate: DexListPresenterDelegate?
    
    private let interactor : DexInteractorProtocol = DexInteractorMock()
    private(set) var state = DexTypes.State.isLoading
    private(set) var models: [DexTypes.DTO.DexListModel] = []
    private let bag = DisposeBag()

    //MARK: - TableData
    
    func modelForIndexPath(_ indexPath: IndexPath) -> DexTypes.DTO.DexListModel {
        return models[indexPath.row]
    }
 
    var numberOfRows: Int {
        if state == .isLoading {
            return 4
        }
        return models.count
    }
    
    func setupObservable() {
        self.interactor.dexPairs().subscribe(onNext: { (result) in
            self.state = .normal
            self.models = result
            self.delegate?.dexListPresenter(listPresenter: self, didUpdateModels: self.models)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.bag)
    }
}


//MARK: - Test Data

extension DexListPresenter {
    
    func simulateDataFromServer() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.interactor.dexPairs().subscribe(onNext: { (result) in
                self.state = .normal
                self.models = result
                self.delegate?.dexListPresenter(listPresenter: self, didUpdateModels: self.models)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.bag)
        }
    }
  
    
}
