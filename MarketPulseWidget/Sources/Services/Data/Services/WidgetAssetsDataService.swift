//
//  WidgetAssetsDataService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

protocol WidgetAssetsDataServiceProtocol {
    
    func assets(ids: [String]) -> Observable<[DataService.DTO.Asset]>
}

final class WidgetAssetsDataService: WidgetAssetsDataServiceProtocol {
   
    func assets(ids: [String]) -> Observable<[DataService.DTO.Asset]> {
        return Observable.empty()
    }
}
