//
//  MyOrdersTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 20.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions
import WavesSDK

enum MyOrdersTypes {
    enum DTO {}
    enum ViewModel {}
    
     enum Event {
        case readyView
        case setOrders([DomainLayer.DTO.Dex.MyOrder])
        case refresh
        case cancelAllOrders
        case ordersDidFinishCancelSuccess
        case ordersDidFinishCancelError(NetworkError)
        case cancelOrder(DomainLayer.DTO.Dex.MyOrder)
      }
      
      struct State: Mutating {
        enum UIAction {
            case none
            case update
            case ordersDidFinishCanceledSuccess
            case ordersDidFinishCanceledError(NetworkError)
        }
          
        enum CoreAction: Equatable {
            case none
            case loadOrders
            case cancelAllOrders
            case cancelOrder(orderId: String, amountAsset: String, priceAsset: String)
        }
        
        var uiAction: UIAction
        var coreAction: CoreAction
        var section: MyOrdersTypes.ViewModel.Section
        var orders: [DomainLayer.DTO.Dex.MyOrder]
      }
}

extension MyOrdersTypes.ViewModel {
 
    enum Status: Int {
        case all = 0
        case active
        case closed
        case canceled
    }
    
    struct Section: Mutating {
        var allItems: [Row]
        var activeItems: [Row]
        var closedItems: [Row]
        var canceledItems: [Row]

        static var empty: Section {
            return .init(allItems: [],
                         activeItems: [],
                         closedItems: [],
                         canceledItems: [])
        }
    }

    enum Row {
        case order(DomainLayer.DTO.Dex.MyOrder)
        case skeleton
        case emptyData
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm:ss"
        return formatter
    }()
}

extension DomainLayer.DTO.Dex.MyOrder {
    
    var isActive: Bool {
        return status == .accepted || status == .partiallyFilled
    }
}

extension MyOrdersTypes.ViewModel.Row {
    var order: DomainLayer.DTO.Dex.MyOrder? {
        switch self {
        case .order(let order):
            return order
            
        default:
            return nil
        }
    }
}

extension MyOrdersTypes.State: Equatable {
    
    static func == (lhs: MyOrdersTypes.State, rhs: MyOrdersTypes.State) -> Bool {
        return lhs.coreAction == rhs.coreAction
    }
}

extension MyOrdersTypes.ViewModel.Section {
    func items(tableIndex: Int) -> [MyOrdersTypes.ViewModel.Row] {
        guard let status = MyOrdersTypes.ViewModel.Status(rawValue: tableIndex) else { return [] }
        
        switch status {
        case .all:
            return allItems
        
        case .active:
            return activeItems
            
        case .canceled:
            return canceledItems
        
        case .closed:
            return closedItems
        }
    }
}
