//
//  Widgets.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    enum Widgets: AnalyticManagerEventInfo {
        
        public enum Style {
            case dark
            case classic
        }
        
        public enum Interval {
            case m1
            case m5
            case m10
            case manually
            
            public var title: String {
                switch self {
                case .m1:
                    return "1m"
                
                case .m5:
                    return "5m"
                
                case .m10:
                    return "10m"
                
                case .manually:
                    return "manually"
                }
            }
        }
        
        public typealias AssetsIds = [String]
        
        
        case marketPulseActive
        case marketPulseAdded
        case marketPulseRemoved
        case marketPulseChanged(Style, Interval, AssetsIds)

        public var name: String {
            
            switch self {
            case .marketPulseActive:
                return "Market Pulse Active"
                
            case .marketPulseAdded:
                return "Market Pulse Added"
                
            case .marketPulseRemoved:
                return "Market Pulse Removed"
                
            case .marketPulseChanged:
                return "Market Pulse Settings Changed"
            }
        }
        
        public var params: [String : String] {
            switch self {
                
            case .marketPulseChanged(let style, let interval, let assetsIds):
                return ["Style": style == .classic ? "Classic" : "Dark",
                        "Interval": interval.title,
                        "Assets": assetsIds.joined(separator: ",")]
            default:
                return [:]
            }
        }
    }
}
