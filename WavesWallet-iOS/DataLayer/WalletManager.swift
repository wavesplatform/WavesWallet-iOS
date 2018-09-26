import Foundation
import KeychainAccess
import LocalAuthentication
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

@available(*, deprecated, message: "need remove")
struct Wallet {
    let name: String
    let publicKeyAccount: PublicKeyAccount
    var matcherKeyAccount: PublicKeyAccount?
    var privateKey: PrivateKeyAccount?
    var isBackedUp = false

    var address: String {
        return publicKeyAccount.address
    }

    var publicKey: [UInt8] {
        return publicKeyAccount.publicKey
    }

    var publicKeyStr: String {
        return publicKeyAccount.getPublicKeyStr()
    }

    init(name: String,
         publicKeyAccount: PublicKeyAccount,
         isBackedUp: Bool) {
        self.name = name
        self.publicKeyAccount = publicKeyAccount
        self.isBackedUp = isBackedUp
    }
}

@available(*, deprecated, message: "need remove")
public enum WalletError: Error {
    case Generic(String)
}

@available(*, deprecated, message: "need remove")
extension WalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .Generic(let msg): return msg
        }
    }
}

@available(*, deprecated, message: "need remove")
class WalletManager {
    static var bag = DisposeBag()

    static var currentWallet: Wallet?

    class func getWalletRealmConfig(waletItem: WalletItem) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.objectTypes = [WalletItem.self]
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(waletItem.address).realm")
        return config
    }

    class func didLogin(toWallet: WalletItem) {
        Realm.Configuration.defaultConfiguration = getWalletRealmConfig(waletItem: toWallet)

        let realm = WalletManager.getWalletsRealm()
        let wallets = realm.objects(WalletItem.self)
        try! realm.write {
            wallets.setValue(false, forKeyPath: "isLoggedIn")
            realm.create(WalletItem.self, value: ["publicKey": toWallet.publicKey, "isLoggedIn": true], update: true)
        }

        currentWallet = toWallet.toWallet
        bag = DisposeBag()
        StoryboardManager.didEndLogin()
    }

    class func didLogout() {
        let realm = WalletManager.getWalletsRealm()
        let wallets = realm.objects(WalletItem.self)
        try! realm.write {
            wallets.setValue(false, forKeyPath: "isLoggedIn")
        }
        currentWallet = nil
        bag = DisposeBag()
        StoryboardManager.didLogout()
    }

    class func getAddress() -> String {
        return currentWallet?.address ?? "Unknown"
    }

    class func getWalletPublicKey() -> Observable<PublicKeyAccount> {
        return Observable.just(currentWallet?.publicKeyAccount ?? PublicKeyAccount(publicKey: []))
    }


    class func getWalletsConfig() -> Realm.Configuration {
        var config = Realm.Configuration()
        config.schemaVersion = 2
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("wallets_\(Environments.current.scheme).realm")
        config.migrationBlock = { _, oldSchemaVersion in
            print("Migration!!! \(oldSchemaVersion)")
        }

        return config
    }

    class func getWalletsRealm() -> Realm {
        let realm = try! Realm(configuration: getWalletsConfig())
        return realm
    }

    class func restorePrivateKeyFromKeychain() -> Observable<PrivateKeyAccount> {
        let keychain = Keychain(service: "com.wavesplatform.wallets")

        return Observable<PrivateKeyAccount>.create { observer -> Disposable in
            // DispatchQueue.global().async {
            do {
                if let pubKey = currentWallet?.publicKeyStr,
                    let restoredSeed = try keychain
                    .authenticationPrompt("Authenticate to decrypt wallet private key and confirm your transaction")
                    .get(pubKey) {
                    observer.onNext(PrivateKeyAccount(seed: Base58.decode(restoredSeed)))
                } else {
                    observer.onError(WalletError.Generic("Private key is not found in Keychain"))
                }

            } catch let error {
                observer.onError(error)
            }
            // }

            return Disposables.create()
        }.subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    class func restorePrivateKeyFromRealm() -> Observable<PrivateKeyAccount> {
        
        return AskManager.askForPassword().flatMap { pwd -> Observable<PrivateKeyAccount>in
            if let realm = getWalletSeedRealm(address: getAddress(), password: pwd) {
                let item = realm.object(ofType: SeedItem.self, forPrimaryKey: currentWallet!.publicKeyStr)
                if let item = item {
                    return Observable.just(PrivateKeyAccount(seed: Array(item.seed.utf8)))
                } else {
                    return Observable.error(WalletError.Generic("Private key is not found in Realm"))
                }
            } else {
                return Observable.error(WalletError.Generic("Incorrect password. Try again."))
            }
        }
    }

    class func restorePrivateKey() -> Observable<PrivateKeyAccount> {
        return restorePrivateKeyFromKeychain()
            .catchError { err in
                if isSeedRealmExist() {
                    return restorePrivateKeyFromRealm()
                } else {
                    return Observable<PrivateKeyAccount>.error(err)
                }
            }.observeOn(MainScheduler.instance)
    }

    class func removePrivateKey(publicKey: String) -> Error? {
        let keychain = Keychain(service: "com.wavesplatform.wallets")

        do {
            try keychain.remove(publicKey)
        } catch let error {
            return error
        }
        return nil
    }

    class func clearPrivateMemoryKey() {
        WalletManager.currentWallet?.privateKey = nil
    }

    class func getPrivateKey(complete: @escaping (_ key: PrivateKeyAccount) -> Void,
                             fail: @escaping (_ errorMessage: String) -> Void) {
        if let key = WalletManager.currentWallet?.privateKey {
            complete(key)
        } else {
            WalletManager.restorePrivateKey()
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { pk in
                    WalletManager.currentWallet?.privateKey = pk
                    complete(pk)
                }, onError: { err in
                    fail(err.localizedDescription)
                })
                .disposed(by: bag)
        }
    }

    class func isSeedRealmExist() -> Bool {
        return FileManager().fileExists(atPath: getWalletSeedRealmConfig(address: getAddress(), password: "").fileURL!.path)
    }

    class func getWalletSeedRealmConfig(address: String, password: String) -> Realm.Configuration {
        var config = Realm.Configuration(encryptionKey: Data(bytes: Hash.sha512(Array(password.utf8))))
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(address)_seed.realm")
        return config
    }

    class func getWalletSeedRealm(address: String, password: String) -> Realm? {
        do {
            let realm = try Realm(configuration: getWalletSeedRealmConfig(address: address, password: password))
            return realm
        } catch _ as NSError {
            // If the encryption key is wrong, `error` will say that it's an invalid database
            return nil
        }
    }

    class func saveSeedRealm(address: String, publicKeyStr: String, password: String, seedBytes: [UInt8]) -> Observable<Void> {
        do {
            let realm = getWalletSeedRealm(address: address, password: password)!
            try realm.write {
                realm.create(SeedItem.self, value: ["publicKey": publicKeyStr, "seed": String(data: Data(seedBytes), encoding: .utf8)], update: true)
            }
            return Observable<Void>.just(())
        } catch let err {
            return Observable.error(WalletError.Generic("Failed to save seed in Realm: " + err.localizedDescription))
        }
    }

    class func saveSeedRealm(password: String) -> Observable<Void> {
        guard let wallet = currentWallet else {
            return Observable.error(WalletError.Generic("User is not logged in"))
        }

        return restorePrivateKey()
            .flatMap { pk -> Observable<Void> in
                saveSeedRealm(address: wallet.address, publicKeyStr: wallet.publicKeyStr, password: password, seedBytes: pk.seed)
            }
    }

    class func saveToRealm(wallet: WalletItem) {
        let realm = WalletManager.getWalletsRealm()
        let w = WalletItem()
        w.publicKey = wallet.publicKey
        w.name = wallet.name
        try! realm.write {
            realm.add(w, update: true)
        }
    }

    class func isTouchIdAvailable() -> Bool {
        let myContext = LAContext()

        var authError: NSError?
        if #available(iOS 8.0, *) {
            return myContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError)
        } else {
            return false
        }
    }

    class func createWalletInRealm(wallet: WalletItem, seedBytes: [UInt8]) -> Observable<Void> {
        return AskManager.askForSetPassword()
            .flatMap { pwd -> Observable<Void> in
                saveSeedRealm(address: wallet.address, publicKeyStr: wallet.publicKey, password: pwd, seedBytes: seedBytes)
            }
    }

    class func createWalletInKeychain(wallet: WalletItem, seedBytes: [UInt8]) -> Observable<Void> {
        let seed = Base58.encode(seedBytes)
        let keychain = Keychain(service: "com.wavesplatform.wallets")
            .label("Waves wallet seeds")
            .accessibility(.whenUnlocked)

        return Observable<Void>.create { observer -> Disposable in
            do {
                let policy = AuthenticationPolicy.userPresence

                try keychain
                    .authenticationPrompt("Authenticate to store encrypted wallet private key")
                    .accessibility(.whenUnlocked, authenticationPolicy: policy)
                    .set(seed, key: wallet.publicKey)

            } catch let err {
                observer.onError(WalletError.Generic("Failed to store your seed in Keychain: " + err.localizedDescription))
            }

            observer.onNext(())
            return Disposables.create()
        }.subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    class func createWallet(wallet: WalletItem, seedBytes: [UInt8]) {
        createWalletInRealm(wallet: wallet,
                            seedBytes: seedBytes)
            .flatMap { () -> Observable<Void> in
                if isTouchIdAvailable() {
                    return createWalletInKeychain(wallet: wallet, seedBytes: seedBytes)
                } else {
                    return Observable<Void>.just(())
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                saveToRealm(wallet: wallet)
                didLogin(toWallet: wallet)
            }, onError: { err in
                AskManager.presentBasicAlertWithTitle(title: "Failed to store your seed", message: err.localizedDescription)
            })
            .disposed(by: bag)
    }

    class func deleteWallet(walletItem: WalletItem) {
        WalletManager.clearPrivateMemoryKey()

        if let err = WalletManager.removePrivateKey(publicKey: walletItem.publicKey) {
            AskManager.presentBasicAlertWithTitle(title: err.localizedDescription)
        }

        let realmURL = getWalletRealmConfig(waletItem: walletItem).fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management"),
            getWalletSeedRealmConfig(address: walletItem.address, password: "").fileURL!
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {
                // handle error
            }
        }

        let realm = WalletManager.getWalletsRealm()
        try! realm.write {
            realm.delete(walletItem)
        }
    }

    static var isWalletLoggedIn: (isLoggedIn: Bool, item: WalletItem?) {
        let realm = WalletManager.getWalletsRealm()
        let w = realm.objects(WalletItem.self).filter("isLoggedIn == true")
        return (isLoggedIn: w.count > 0, item: w.count > 0 ? w[0] : nil)
    }
}

//extension WalletManager {
//    class func getPrivateKey() -> Observable<PrivateKeyAccount> {
//        return Observable.create { event -> Disposable in
//
//            WalletManager.getPrivateKey(complete: { account in
//                event.onNext(account)
//                event.onCompleted()
//            }, fail: { error in
//                event.onError(WalletError.Generic(error))
//            })
//
//            return Disposables.create()
//        }
//    }
//}
