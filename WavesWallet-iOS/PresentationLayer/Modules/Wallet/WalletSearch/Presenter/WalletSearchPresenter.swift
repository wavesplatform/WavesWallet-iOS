//
//  WalletSearchPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxCocoa
import RxSwift

protocol WalletSearchPresenterProtocol {
    typealias Feedback = (Driver<WalletSearch.State>) -> Signal<WalletSearch.Event>
    func system(feedbacks: [Feedback])
}

final class WalletSearchPresenter: WalletSearchPresenterProtocol {
    
    private let assets: [DomainLayer.DTO.SmartAssetBalance]
    private let disposeBag = DisposeBag()
    
    init(assets: [DomainLayer.DTO.SmartAssetBalance]) {
        self.assets = assets//.sorted(by: {$0.settings.sortLevel > $1.settings.sortLevel})
    }
    
    func system(feedbacks: [WalletSearchPresenter.Feedback]) {
        
        let newFeedbacks = feedbacks
        
        Driver.system(initialState: WalletSearch.State.initialState(assets: assets),
                      reduce: { [weak self] state, event in
                        guard let self = self else { return state }
                        return self.reduce(state: state, event: event)
            },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func reduce(state: WalletSearch.State, event: WalletSearch.Event) -> WalletSearch.State {
        
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }
    
    private func reduce(state: inout WalletSearch.State, event: WalletSearch.Event)  {
        
        switch event {
            
        case .readyView:
            state.action = .refresh
            
        case .search(let searchString):
            state.action = .refresh
            state.sections = WalletSearch.ViewModel.Section.map(from: assets, searchString: searchString)
        }
        
    }
}


private extension WalletSearch.State {
    
    static func initialState(assets: [DomainLayer.DTO.SmartAssetBalance]) -> WalletSearch.State {
        
        return WalletSearch.State(assets: assets,
                                  sections: WalletSearch.ViewModel.Section.map(from: assets),
                                  action: .none)
    }

}

extension WalletSearch.ViewModel.Section {
    
    static func map(from assets: [DomainLayer.DTO.SmartAssetBalance], searchString: String) -> [WalletSearch.ViewModel.Section] {
       
        if searchString.count == 0 {
            return map(from: assets)
        }
        
        let searchAssets = assets.filter{ $0.asset.displayName.lowercased().contains(searchString.lowercased()) }
        
        let generalItems = searchAssets
            .filter { $0.asset.isSpam != true && $0.settings.isHidden != true }
            .map { WalletSearch.ViewModel.Row.asset($0) }
        
        var hiddenItems = searchAssets
            .filter { $0.settings.isHidden == true }
            .map { WalletSearch.ViewModel.Row.asset($0) }

        var spamItems = searchAssets
            .filter { $0.asset.isSpam == true }
            .map { WalletSearch.ViewModel.Row.asset($0) }
        
        var sections: [WalletSearch.ViewModel.Section] = []
        
        if generalItems.count > 0 {
            
            let generalSection: WalletSearch.ViewModel.Section = .init(kind: .assets,
                                                                       items: generalItems)
            sections.append(generalSection)
        }
        
        if hiddenItems.count > 0 {
            hiddenItems.insert(.header(.hidden), at: 0)
            let hiddenSection: WalletSearch.ViewModel.Section = .init(kind: .hidden,
                                                                      items: hiddenItems)
            sections.append(hiddenSection)
        }

        if spamItems.count > 0 {
            
            spamItems.insert(.header(.spam), at: 0)
            let spamSection: WalletSearch.ViewModel.Section = .init(kind: .spam,
                                                                    items: spamItems)
            sections.append(spamSection)
        }
        
        return sections
    }
    
    static func map(from assets: [DomainLayer.DTO.SmartAssetBalance]) -> [WalletSearch.ViewModel.Section] {
        
        let generalItems = assets
            .filter { $0.asset.isSpam != true && $0.settings.isHidden != true }
            .map { WalletSearch.ViewModel.Row.asset($0) }

        return [.init(kind: .assets,  items: generalItems)]
    }
}
