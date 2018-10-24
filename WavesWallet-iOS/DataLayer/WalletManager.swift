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

    class func getAddress() -> String {
        return currentWallet?.address ?? "Unknown"
    }

    class func getWalletPublicKey() -> Observable<PublicKeyAccount> {
        return Observable.just(currentWallet?.publicKeyAccount ?? PublicKeyAccount(publicKey: []))
    }

    class func clearPrivateMemoryKey() {
        WalletManager.currentWallet?.privateKey = nil
    }

    class func getPrivateKey(complete: @escaping (_ key: PrivateKeyAccount) -> Void,
                             fail: @escaping (_ errorMessage: String) -> Void) {
        if let key = WalletManager.currentWallet?.privateKey {
            complete(key)
        }
    }

}
