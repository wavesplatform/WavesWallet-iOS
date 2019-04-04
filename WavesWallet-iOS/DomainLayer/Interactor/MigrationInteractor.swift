//
//  MigrationInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift

fileprivate struct ApplicationVersion: Codable, TSUD {

    private static let key: String = "com.waves.migrator.version"

    static var defaultValue: String {
        return ""
    }

    static var stringKey: String {
        return ApplicationVersion.key
    }
}

final class SweetMigration {

    typealias Migration = () -> Observable<Void>

    private struct Version {
        let version: String
        let migration: Migration
    }

    private var versions: [Version] = []

    func register(targetVersion: String, migration: @escaping Migration) {
        let version = Version(version: targetVersion, migration: migration)
        versions.append(version)
    }

    func run() -> Observable<Void> {

        let currentVersion = ApplicationVersion.get()

        let versions = self.versions.sorted(by: { (v1, v2) -> Bool in
            return v1.version.compare(v2.version) == .orderedAscending
        })
        .filter { (version) -> Bool in
            return version.version.compare(currentVersion) == .orderedDescending
        }

        let lastVersion = versions.last?.version ?? currentVersion

        return Observable
            .merge(versions.map { $0.migration() })
            .do(onCompleted: {
                ApplicationVersion.set(lastVersion)
            })
    }
}

final class MigrationInteractor {

    private var walletsRepository: WalletsRepositoryProtocol

    private var sweetMigration: SweetMigration = SweetMigration()

    init(walletsRepository: WalletsRepositoryProtocol) {
        self.walletsRepository = walletsRepository
    }

    func migration() -> Observable<Void> {

        sweetMigration.register(targetVersion: "2.0") { [weak self] () -> Observable<Void> in
            guard let self = self else { return Observable.never() }
            return self.migration2_0()
        }

        return sweetMigration.run()
    }


    private func migration2_0() -> Observable<Void> {

        let wallets = self
            .walletsRepository
            .wallets()
            .flatMap { wallets -> Observable<[DomainLayer.DTO.Wallet]> in

                let newWallets = wallets.map({ wallet -> DomainLayer.DTO.Wallet in
                    let id = UUID().uuidString
                    let address = PublicKeyAccount(publicKey: Base58.decode(wallet.publicKey)).address
                    return DomainLayer.DTO.Wallet(name: wallet.name,
                                                  address: address,
                                                  publicKey: wallet.publicKey,
                                                  isLoggedIn: false,
                                                  isBackedUp: wallet.isBackedUp,
                                                  hasBiometricEntrance: false,
                                                  id: id)
                })

                return Observable.just(newWallets)
            }
            .flatMap { [weak self] wallets -> Observable<Void> in

                guard let self = self else { return Observable.never() }

                let observers = wallets
                    .compactMap({ [weak self] wallet -> Observable<Void> in

                        guard let self = self else { return Observable.never() }
                        
                        let seedId = UUID().uuidString
                        let migrateOldSeed = self.migrateOldSeed(wallet: wallet, seedId: seedId)
                        let addedWalletEncryption = self.addedWalletEncryption(wallet: wallet, seedId: seedId).map { _ in () }
                        let save = self.walletsRepository.saveWallet(wallet).map { _ in () }
                        return Observable.merge([migrateOldSeed, addedWalletEncryption, save])
                    })

                return Observable.merge(observers)
            }

        return wallets
    }

    private func migrateOldSeed(wallet: DomainLayer.DTO.Wallet, seedId: String) -> Observable<Void> {

        return Observable.create { observer -> Disposable in

            let address = wallet.address
            if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {

                let oldUrl = fileURL
                    .deletingLastPathComponent()
                    .appendingPathComponent("\(address)_seed.realm")

                let newUrl = fileURL
                    .deletingLastPathComponent()
                    .appendingPathComponent("\(address)_seed_\(seedId).realm")

                let oldFileExistsSeed = FileManager.default.fileExists(atPath: oldUrl.path)
                let newFileExistsSeed = FileManager.default.fileExists(atPath: newUrl.path)

                  SweetLogger.debug("exist file old \(oldFileExistsSeed) - new \(newFileExistsSeed)")

                do {
                    if oldFileExistsSeed == true
                        && newFileExistsSeed == false {
                        try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                        SweetLogger.debug("Move \(oldUrl) - \(newUrl)")
                    } else {
                        SweetLogger.debug("Dont Move \(oldUrl) - \(newUrl)")
                    }
                } catch let e {
                    SweetLogger.error(e)
                }

                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    private func addedWalletEncryption(wallet: DomainLayer.DTO.Wallet, seedId: String) -> Observable<DomainLayer.DTO.WalletEncryption> {

        return self.walletsRepository.saveWalletEncryption(.init(publicKey: wallet.publicKey,
                                                                 kind: .none,
                                                                 seedId: seedId))
    }

}
