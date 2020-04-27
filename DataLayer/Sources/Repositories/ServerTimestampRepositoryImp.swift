//
//  ServerTimestampRepositoryImp.swift
//  DataLayer
//
//  Created by rprokofev on 24.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import RxSwift

final class ServerTimestampRepositoryImp: ServerTimestampRepository {
    private let timestampServerService: TimestampServerService
    private let disposeBag: DisposeBag = DisposeBag()

    private var internalServerTimestampDiff: Int64?

    private var serverTimestampDiff: Int64? {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalServerTimestampDiff
        }

        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalServerTimestampDiff = newValue
        }
    }

    init(timestampServerService: TimestampServerService) {
        self.timestampServerService = timestampServerService

        NotificationCenter.default.addObserver(self, selector: #selector(timeDidChange),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)
    }

    func timestampServerDiff(serverEnvironment: ServerEnvironment) -> Observable<Int64> {
        if let time = serverTimestampDiff {
            return Observable.just(time)
        }

        return timestampServerService
            .timestampServerDiff(serverEnvironment: serverEnvironment)
            .flatMap { [weak self] time -> Observable<Int64> in

                guard let self = self else { return Observable.never() }

                self.serverTimestampDiff = time
                return Observable.just(time)
            }
    }
}

private extension ServerTimestampRepositoryImp {
    @objc func timeDidChange() {
        self.serverTimestampDiff = nil
    }
}
