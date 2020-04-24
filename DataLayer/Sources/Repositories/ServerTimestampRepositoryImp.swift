//
//  ServerTimestampRepositoryImp.swift
//  DataLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

final class ServerTimestampRepositoryImp: ServerTimestampRepository {
            
    private let timestampServerService: TimestampServerService
    private let serverTimestampDiffDao: ServerTimestampDiffDao
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(timestampServerService: TimestampServerService,
         serverTimestampDiffDao: ServerTimestampDiffDao) {
        self.timestampServerService = timestampServerService
        self.serverTimestampDiffDao = serverTimestampDiffDao
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(timeDidChange),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
    }
    
    func timestampServerDiff(serverEnvironment: ServerEnvironment) -> Observable<Int64> {
        
        return serverTimestampDiffDao
            .serverTimestampDiffDao()
            .flatMap { [weak self] time -> Observable<Int64> in
                
                guard let self = self else { return Observable.never() }
                
                if let time = time {
                    return Observable.just(time)
                }
                                
                return self
                    .timestampServerService
                    .timestampServerDiff(serverEnvironment: serverEnvironment)
                    .flatMap { [weak self] time -> Observable<Int64> in
                        
                        guard let self = self else { return Observable.never() }
                        
                        return self
                            .serverTimestampDiffDao
                            .setServerTimestampDiffDao(time)
                            .map { $0 ?? time }
                    }
            }
    }
}
private extension ServerTimestampRepositoryImp {
    
    @objc func timeDidChange() {
        
        serverTimestampDiffDao
            .setServerTimestampDiffDao(nil)
            .subscribe()
            .disposed(by: disposeBag)
    }    
}
