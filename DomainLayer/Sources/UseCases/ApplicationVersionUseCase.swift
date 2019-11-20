//
//  ApplicationVersionUseCase.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30/05/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public extension DomainLayer.DTO {
    struct VersionUpdateData {
        public let isNeedForceUpdate: Bool
        public let forceUpdateVersion: String
    }
}

public protocol ApplicationVersionUseCaseProtocol {
    func isHasNewVersion() -> Observable<Bool>
    func isNeedForceUpdate() -> Observable<DomainLayer.DTO.VersionUpdateData>
}

public final class ApplicationVersionUseCase: ApplicationVersionUseCaseProtocol {

    private let applicationVersionRepository: ApplicationVersionRepositoryProtocol
    
    public init(applicationVersionRepository: ApplicationVersionRepositoryProtocol) {
        self.applicationVersionRepository = applicationVersionRepository
    }
    
    public func isHasNewVersion() -> Observable<Bool> {
        
        return applicationVersionRepository
            .version()
            .flatMap { (version) -> Observable<Bool> in
                let currentVersion = Bundle.main.version.versionToInt()
                return Observable.just(currentVersion.lexicographicallyPrecedes(version.versionToInt()))
            }                
    }
    
    public func isNeedForceUpdate() -> Observable<DomainLayer.DTO.VersionUpdateData> {
        return applicationVersionRepository
            .forceUpdateVersion()
            .flatMap { (version) -> Observable<DomainLayer.DTO.VersionUpdateData> in
                let currentVersion = Bundle.main.version.versionToInt()
                
                let isNeedForceUpdate: Bool = currentVersion.lexicographicallyPrecedes(version.versionToInt())
                return Observable.just(DomainLayer.DTO.VersionUpdateData.init(isNeedForceUpdate: isNeedForceUpdate,
                                                                              forceUpdateVersion: version))
            }
        .catchError { (_) -> Observable<DomainLayer.DTO.VersionUpdateData> in
            return Observable.just(DomainLayer.DTO.VersionUpdateData.init(isNeedForceUpdate: false,
                                                                          forceUpdateVersion: ""))
        }
    }
}

private extension String {
    func versionToInt() -> [Int] {
        return self.components(separatedBy: ".")
            .map { Int.init($0) ?? 0 }
    }
}
