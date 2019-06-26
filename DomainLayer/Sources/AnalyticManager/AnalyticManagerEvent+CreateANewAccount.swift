//
//  AnalyticManagerEvent+CreateANewAccount.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum CreateANewAccount: AnalyticManagerEventInfo {
        
        /* Проставлены 3 чекбокса с условиями использования и нажата кнопка "Begin". */
        case newUserConfirm
        
        // При появлении у пользователя сообщения "Нужно забэкапить SEED", отправляем событие
        case newUserWithoutBackup(count: UInt)
        
        public var name: String {
            
            switch self {
            case .newUserConfirm:
                return "New User Confirm"
                
            case .newUserWithoutBackup:
                return "New User Without Backup"
            }
        }
        
        public var params: [String : String] {
            return [:]
        }
    }
}
