//
//  EntityManager.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 03/06/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

final class ApplicationEnviroment {
    
    let services: WavesServicesProtocol
    let enviroment: Enviroment
    
    init(services: WavesServicesProtocol, enviroment: Enviroment) {
        self.services = services
        self.enviroment = enviroment
    }
}

protocol ApplicationEnviromentUseCaseProtocol {
    
    func environment() -> Observable<ApplicationEnviroment>
    
//    func setSpam
}

final class ApplicationEnviromentUseCase: ApplicationEnviromentUseCaseProtocol {
    
    private let enviromentRepository: EnvironmentRepositoryProtocol
    
    init(enviromentRepository: EnvironmentRepositoryProtocol) {
        self.enviromentRepository = enviromentRepository
    }
    
    func environment() -> Observable<ApplicationEnviroment> {
        
        
        enviromentRepository.accountEnvironment(accountAddress: "")
            .flatMap { (enviroment) -> Observable<ApplicationEnviroment> in
                
                
                return Observable.never()
            }
        
        return Observable.never()
    }
    
    private func initilix(enviroment: Enviroment) {
        
        WavesSDK.initialization(servicesPlugins: .init(data: [], node: [], matcher: []),
                                enviroment: .init(server: .custom(node: URL.init(string: "")!, matcher: URL.init(string: "")!, data: URL.init(string: "")!, scheme: ""),
                                                  timestampServerDiff: 0))
    }
}

