//
//  Addressbook.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    enum AddressBook: AnalyticManagerEventInfo {
        
        case transactionAddressSave
        
        case transactionAddressEdit
        
        case profileAddressBookPage
        
        case profileAddressBookAdd
        
        case profileAddressBookEdit
        
        case profileAddressBookDelete
        
        public var name: String {
            switch self {
            case .transactionAddressSave:
                return "Transaction Address Save"
                
            case .transactionAddressEdit:
                return "Transaction Address Edit"
                
            case .profileAddressBookPage:
                return "Profile Address Book Page"
                
            case .profileAddressBookAdd:
                return "Profile Address Book Add"
            
            case .profileAddressBookEdit:
                return "Profile Address Book Edit"
                
            case .profileAddressBookDelete:
                return "Profile Address Book Delete"            
            }
        }
        
        public var params: [String : String] {
            switch self {
                
            default:
                return [:]
            }
        }
    }
}
