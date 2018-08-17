//
//  AssetViewInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AssetInteractorMock: AssetInteractorProtocol {

    func assets() -> Observable<[AssetTypes.DTO.Asset]> {

        do {
            let decoder = JSONDecoder()

            let file = Bundle.main.path(forResource: "Assets", ofType: "json")!
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else { return Observable.just([]) }

            let assets = try decoder.decode([AssetTypes.DTO.Asset].self, from: data)

            return Observable.just(assets)
        } catch let error {
            print(error)
        }

        return Observable.just([])
    }
}
