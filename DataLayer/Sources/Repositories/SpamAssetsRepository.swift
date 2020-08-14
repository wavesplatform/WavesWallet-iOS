//
//  SpamAssetsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 25.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift

final class SpamAssetsRepository: SpamAssetsRepositoryProtocol {
    private let spamService: SpamAssetsService

    private let environmentRepository: EnvironmentRepositoryProtocol
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol

    private var internalSpamAssets: [String: [SpamAssetId]] = [:]

    private var internalSpamAssetsObservables: [String: Observable<[SpamAssetId]>] = [:]

    private var spamAssets: [String: [SpamAssetId]] {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalSpamAssets
        }

        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalSpamAssets = newValue
        }
    }

    private var spamAssetsObservables: [String: Observable<[SpamAssetId]>] {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalSpamAssetsObservables
        }

        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalSpamAssetsObservables = newValue
        }
    }

    init(environmentRepository: EnvironmentRepositoryProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         spamAssetsService: SpamAssetsService) {
        self.environmentRepository = environmentRepository
        self.accountSettingsRepository = accountSettingsRepository
        spamService = spamAssetsService
    }

    func spamAssets(accountAddress: String) -> Observable<[SpamAssetId]> {
        if let spamAssets = spamAssets[accountAddress] {
            return Observable.just(spamAssets)
        }

        if let observer = spamAssetsObservables[accountAddress] {
            return observer
        }

        let observer = accountSettingsRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap { [weak self] accountEnviroment -> Observable<[SpamAssetId]> in

                guard let self = self else { return Observable.never() }

                if let accountEnviroment = accountEnviroment,
                    let spamPath = accountEnviroment.spamUrl,
                    let spamUrl = URL(string: spamPath) {
                    return self.downloadSpamAssets(by: spamUrl)
                } else {
                    return self.downloadDeffaultSpamAssets()
                }
            }
            .do(onNext: { [weak self] spamAssets in
                self?.spamAssets[accountAddress] = spamAssets
            })
            .share(replay: 1, scope: SubjectLifetimeScope.forever)

        spamAssetsObservables[accountAddress] = observer

        return observer
    }

    private func downloadDeffaultSpamAssets() -> Observable<[SpamAssetId]> {
        return environmentRepository.walletEnvironment()
            .flatMap { [weak self] (environment) -> Observable<[String]> in

                guard let self = self else { return Observable.empty() }

                return self
                    .spamService
                    .spamAssets(by: environment.servers.spamUrl)
            }
    }

    private func downloadSpamAssets(by url: URL) -> Observable<[SpamAssetId]> {
        return environmentRepository.walletEnvironment()
            .flatMap { [weak self] (_) -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self
                    .spamService
                    .spamAssets(by: url)
            }
    }
}
