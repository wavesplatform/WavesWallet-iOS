//
//  HistoryTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer


extension HistoryTypes.State {
    static func initialState(historyType: HistoryType) -> HistoryTypes.State {

        return HistoryTypes.State(currentFilter: .all,
                                  filters: historyType.filters,
                                  transactions: [],
                                  sections: self.skeletonSections(),
                                  isRefreshing: false,
                                  isAppeared: false,
                                  refreshData: .refresh,
                                  errorState: .none)
    }

    static func skeletonSections() -> [HistoryTypes.ViewModel.Section] {
        return  [HistoryTypes.ViewModel.Section(items: [.transactionSkeleton,
                                                        .transactionSkeleton,
                                                        .transactionSkeleton,
                                                        .transactionSkeleton,
                                                        .transactionSkeleton,
                                                        .transactionSkeleton,
                                                        .transactionSkeleton])]
    }
}
