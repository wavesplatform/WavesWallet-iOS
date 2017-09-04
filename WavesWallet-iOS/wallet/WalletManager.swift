import Foundation
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import KeychainAccess

class WalletItem: Object {
    dynamic var publicKey = ""
    dynamic var name = ""
    dynamic var isLoggedIn = false
    dynamic var isBackedUp = false
    
    public var identity: String {
        return "\(publicKey)"
    }
    override static func primaryKey() -> String? {
        return "publicKey"
    }
    
    var address: String {
        return publicKeyAccount.address
    }
    
    var publicKeyAccount: PublicKeyAccount {
        return PublicKeyAccount(publicKey: Base58.decode(publicKey))
    }
    
    var toWallet: Wallet {
        return Wallet(name: name, publicKeyAccount: publicKeyAccount)
    }
}

struct Wallet {
    let name: String
    let publicKeyAccount: PublicKeyAccount
    var matcherKeyAccount: PublicKeyAccount?
    var privateKey: PrivateKeyAccount?

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
         publicKeyAccount: PublicKeyAccount) {
        self.name = name
        self.publicKeyAccount = publicKeyAccount
    }
}

func == (lhs: WalletItem, rhs: WalletItem) -> Bool {
    return lhs.publicKey == rhs.publicKey
}

public enum WalletError : Error {
    case Generic(String)
}

class WalletManager {
    
    static var bag = DisposeBag()
    
    static var currentWallet: Wallet? {
        didSet {
            bag = DisposeBag()
        }
    }

    class func didLogin(toWallet: WalletItem) {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(toWallet.address).realm")
        Realm.Configuration.defaultConfiguration = config
       
        let realm = WalletManager.getWalletsRealm()
        let wallets = realm.objects(WalletItem.self)
        try! realm.write {
            wallets.setValue(false, forKeyPath: "isLoggedIn")
            realm.create(WalletItem.self, value: ["publicKey": toWallet.publicKey, "isLoggedIn": true], update: true)
        }

        currentWallet = toWallet.toWallet
        StoryboardManager.didEndLogin()
        autoUpdateFromNode()
    }
    
    class func updateTransactions(onComplete: (() -> ())?) {
        let load = Observable.from([NodeManager.loadTransaction(), NodeManager.loadPendingTransaction()])
            .merge().toArray()
            .map { Array($0.joined()) }
        
        load
            .catchError { err in
                print(err)
                return Observable.empty()
            }
            .subscribe(onNext: {txs in
                let realm = try! Realm()
                try! realm.write {
                    realm.add(txs, update: true)
                    realm.add(txs.map { tx in
                        let bt = BasicTransaction(tx: tx)
                        bt.addressBook = realm.create(AddressBook.self, value: ["address": bt.counterParty], update: true)
                        return bt
                    }, update: true)
                }
                if let onComplete = onComplete {
                    onComplete()
                }
            })
            .addDisposableTo(bag)
    }

    class func autoUpdateFromNode() {
        _ = Observable<Int>
            .timer(30, period: 30, scheduler: MainScheduler.instance)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .subscribe(onNext: {_ in
                print(Date())
                updateBalances(onComplete: nil)
                updateTransactions(onComplete: nil)
            })
            .addDisposableTo(bag)
    }

    class func updateBalances(onComplete: (() -> ())?) {
        let load = Observable.from([NodeManager.loadWavesBalance(), NodeManager.loadBalances()])
                .merge().toArray()
                .map { Array($0.joined()) }
      
        load
            .catchError { err in
                print(err)
                return Observable.empty()
            }
            .subscribe(onNext: {abs in
                let realm = try! Realm()
                try! realm.write {
                    let oldHiddenIds = Array(realm.objects(AssetBalance.self).filter("isHidden = true").map{ $0.assetId })
                    realm.add(abs, update: true)
                    
                    let generalAssetsIds = Environments.current.generalAssetIds.map{ $0.assetId }
                    realm.objects(AssetBalance.self).filter("assetId in %@", generalAssetsIds)
                        .setValue(true, forKeyPath: "isGeneral")
                    
                    realm.objects(AssetBalance.self).filter("assetId in %@", oldHiddenIds)
                        .setValue(true, forKeyPath: "isHidden")
                    
                    let ids = abs.map{ $0.assetId}
                    let deleted = realm.objects(AssetBalance.self).filter("isGeneral = false AND NOT (assetId in %@)", ids)
                    realm.delete(deleted)
                }
                if let onComplete = onComplete {
                    onComplete()
                }
            })
            .addDisposableTo(bag)
    }
    
    class func didLogout() {
        let realm = WalletManager.getWalletsRealm()
        let wallets = realm.objects(WalletItem.self)
        try! realm.write {
            wallets.setValue(false, forKeyPath: "isLoggedIn")
        }
        currentWallet = nil
        StoryboardManager.didLogout()
    }
    
    class func getAddress() -> String {
        return currentWallet?.address ?? "Unknown"
    }
    
    class func getWalletPublicKey() -> Observable<PublicKeyAccount> {
        return Observable.just(currentWallet?.publicKeyAccount ?? PublicKeyAccount(publicKey: []))
    }
    
    class func getWavesBalance() -> Observable<Int64> {
       return getWavesAssetBalance().map { $0.balance }
    }
    
    class func getWavesAssetBalance() -> Observable<AssetBalance> {
        let realm = try! Realm()
        let rAccount = realm.object(ofType: AssetBalance.self, forPrimaryKey: "")
        
        guard let waves = rAccount else { return Observable.just(AssetBalance()) }
        
        return Observable.from(object: waves).distinctUntilChanged{ $0 == $1 }
    }
    
    class func getWalletsConfig() -> Realm.Configuration {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("wallets_\(Environments.current.scheme).realm")
        return config
    }
    
    class func getWalletsRealm() -> Realm {
        let realm = try! Realm(configuration: getWalletsConfig())
        return realm
    }
    
    class func restorePrivateKey() -> Observable<PrivateKeyAccount> {
        let keychain = Keychain(service: "com.wavesplatform.wallets")
        
        return Observable<PrivateKeyAccount>.create {observer -> Disposable in
            DispatchQueue.global().async {
                do {
                    if let pubKey = currentWallet?.publicKeyStr,
                        let restoredSeed = try keychain
                            .authenticationPrompt("Authenticate to decrypt wallet private key and confirm your transaction")
                            .get(pubKey) {
                        observer.onNext(PrivateKeyAccount(seed: Base58.decode(restoredSeed)))
                    } else {
                        observer.onError(WalletError.Generic("Private key is not founf"))
                    }
                    
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
        
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
    
    class func getPrivateKey(complete: @escaping(_ key: PrivateKeyAccount) -> Void, fail:@escaping (_ errorMessage: String) -> Void) {
        if let key = WalletManager.currentWallet?.privateKey {
            complete(key)
        }
        else {
            
            WalletManager.restorePrivateKey().subscribe(onNext: { (key) in
                WalletManager.currentWallet?.privateKey = key
                complete(key)
            }.addDisposableTo(bag)
        }
    }
}
