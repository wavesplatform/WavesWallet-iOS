//
//  DateFormatter+UI.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/04/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation

public extension DateFormatter {

    enum DateFormatStyle {
        case pretty(Date)
        
        var dateFormat: String {
            
            switch self {
            case .pretty(let date):
                if date.isThisYear {
                    if date.isThisMonth {
                        if date.isToday {
                            return "hh:mm"
                        } else {
                            return "MMM dd hh:mm"
                        }
                    } else {
                        return "MMM dd, yyyy\nhh:mm"
                    }
                } else {
                    return "MMM dd, yyyy\nhh:mm"
                }            
            }
        }
    }
    
    static func uiSharedFormatter(key: String) -> DateFormatter {
        let formatter = Thread
            .threadSharedObject(key: key,
                                create: { return DateFormatter() })

        formatter.locale = Localizable.locale
        return formatter
    }
    
    static func uiSharedFormatter(key: String,
                                  style: DateFormatter.DateFormatStyle) -> DateFormatter {
        let formatter = DateFormatter.uiSharedFormatter(key: key)
        formatter.dateFormat = style.dateFormat
        return formatter
    }
    
    func setStyle(_ style: DateFormatter.DateFormatStyle) {
        self.dateFormat = style.dateFormat
    }
}

