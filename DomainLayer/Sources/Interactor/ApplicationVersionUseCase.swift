//
//  ApplicationVersionUseCase.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30/05/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public final class ApplicationVersionUseCase {
    
    private let applicationVersionRepository: ApplicationVersionRepositoryProtocol
    
    init(applicationVersionRepository: ApplicationVersionRepositoryProtocol) {
        self.applicationVersionRepository = applicationVersionRepository
    }
    
    func isHasNewVersion() -> Observable<Bool> {
        
        return applicationVersionRepository
            .version()
            .flatMap { (version) -> Observable<Bool> in
                let currentVersion = Bundle.main.version.versionToInt()
                return Observable.just(currentVersion.lexicographicallyPrecedes(version.versionToInt()))
            }                
    }
}

private extension String {
    func versionToInt() -> [Int] {
        return self.components(separatedBy: ".")
            .map { Int.init($0) ?? 0 }
    }
}
