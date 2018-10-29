//
//  CreateAliasTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum CreateAliasTypes {
    enum ViewModel { }
}

extension CreateAliasTypes {

    enum Query: Equatable {
        
    }

    struct State: Mutating {        
        var query: Query?
        var displayState: DisplayState
    }

    enum Event {
        case viewWillAppear
        case viewDidDisappear
        case input(String)
        case completedQuery
    }

    struct DisplayState: Mutating, DataSourceProtocol {

        enum Action {
            case none
            case update
        }

        var sections: [ViewModel.Section]
        var input: String?
        var isAppeared: Bool
        var action: Action?
    }
}

extension CreateAliasTypes.ViewModel {

    enum Row {
        case input(String)
    }

    struct Section: SectionBase, Mutating {
        var rows: [Row]
    }
}
