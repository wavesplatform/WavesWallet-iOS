//
//  WidgetSettingsUseCaseProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public extension DomainLayer.DTO {
    enum Widget {}
}

public extension DomainLayer.DTO.Widget {

    static let defaultCountAssets: Int = 4
    static let minCountAssets: Int = 2
    static let maxCountAssets: Int = 9
    
    enum Interval {
        case m1
        case m5
        case m10
        case manually
    }
    
    enum Style {
        case classic
        case dark
    }
    
    struct Settings {
        public let assets: [Asset]
        public let style: Style
        public let interval: Interval

        public init(assets: [Asset], style: Style, interval: Interval) {
            self.assets = assets
            self.style = style
            self.interval = interval
        }
    }
}


public protocol WidgetSettingsUseCaseProtocol {
    
    func settings() -> Observable<DomainLayer.DTO.Widget.Settings>
    
    func saveSettings(_ settings: DomainLayer.DTO.Widget.Settings) -> Observable<DomainLayer.DTO.Widget.Settings>
    
    func changeInterval(_ interval: DomainLayer.DTO.Widget.Interval) -> Observable<Bool>
    
    func changeStyle(_ style: DomainLayer.DTO.Widget.Style) -> Observable<Bool>
 
    func removeAsset(_ asset: Asset) -> Observable<Bool>
    
    func sortAssets(_ sortMap: [String: Int]) -> Observable<Bool>
}
