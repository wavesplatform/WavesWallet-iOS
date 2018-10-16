import Foundation
import RxSwift
import RxAlamofire
import Gloss
import RealmSwift
import Alamofire

public enum ApiError : Error {
    case IncorrectResponseFormat
    case ServerError(String)
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .IncorrectResponseFormat: return "Unknown response from server"
        case .ServerError(let msg): return "Server error: \(msg)"
        }
    }
}


class NodeManager {
    class func loadTransaction() -> Observable<[Transaction]> {
        let address = WalletManager.getAddress()
        let u = Environments.current.servers.nodeUrl.appendingPathComponent("/transactions/address/\(address)/limit/50")
        return RxAlamofire.requestJSON(.get, u)
            .flatMap { (resp, json) -> Observable<[Transaction]> in
                if let arr = json as? [Any],
                    let jTxs = arr.first as? [JSON] {
                    var txs = [Transaction]()
                    for jTx in jTxs {
                        if let tx = parseTransaction(jTx) { txs += [tx] }
                    }
                    return Observable.just(txs)
                } else {
                    return Observable.error(ApiError.IncorrectResponseFormat)
                }
        }
    }
    
    private class func parseTransaction(_ jTx: JSON) -> Transaction? {
        if let type = jTx["type"] as? Int {
            switch(type) {
            case 3:
                return IssueTransaction(json: jTx)
            case 4:
                return TransferTransaction(json: jTx)
            case 7:
                return ExchangeTransaction(json: jTx)
            default:
                return Transaction(json: jTx)
            }
        }
        return nil
    }
    
    class func loadPendingTransaction() -> Observable<[Transaction]> {
        let u = Environments.current.servers.nodeUrl.appendingPathComponent("/transactions/unconfirmed")
        return RxAlamofire.requestJSON(.get, u)
            .flatMap { (resp, json) -> Observable<[Transaction]> in
                if let jTxs = json as? [JSON] {
                    var txs = [Transaction]()
                    for jTx in jTxs {
                        if let tx = parseTransaction(jTx), tx.isOur() {
                            tx.isPending = true
                            txs += [tx]
                        }
                    }
                    return Observable.just(txs)
                } else {
                    return Observable.error(ApiError.IncorrectResponseFormat)
                }
        }
    }

    class func loadWavesBalance() -> Observable<[AssetBalance]> {
        let u = Environments.current.servers.nodeUrl.appendingPathComponent("/addresses/balance/\(WalletManager.getAddress())")
        return RxAlamofire.requestJSON(.get, u)
            .flatMap { (resp, json) -> Observable<[AssetBalance]> in
                if let res = json as? JSON
                    , let bal = res["balance"] as? Int64 {
                    return Observable.just([createWavesBalance(bal)])
                } else {
                    return Observable.error(ApiError.IncorrectResponseFormat)
                }
        }
    }
    
    class func loadBalances() -> Observable<[AssetBalance]> {
        let u = Environments.current.servers.nodeUrl.appendingPathComponent("/assets/balance/\(WalletManager.getAddress())")
        return RxAlamofire.requestJSON(.get, u)
            .flatMap { (resp, json) -> Observable<[AssetBalance]> in
                if let all = json as? JSON
                    , let jBals = all["balances"] as? [JSON] {
                    var abs = [AssetBalance]()
                    for jb in jBals {
                        if let ab = AssetBalance(json: jb) {
                            abs += [ab]
                        }
                    }
                    return Observable.just(abs)
                } else {
                    return Observable.error(ApiError.IncorrectResponseFormat)
                }
        }
    }
    
    static let realm = {
        try! Realm()
    }()
    
    class func createGeneralBalance(_ id: String, bal: Int64, name: String) -> AssetBalance {
        let ab = AssetBalance()
        ab.balance = bal
        ab.isGeneral = true
        ab.assetId = id
        let issue = IssueTransaction()
        issue.id = id
        issue.name = name
        ab.issueTransaction = issue
        return ab
    }
    
    class func createWavesBalance(_ bal: Int64) -> AssetBalance {
        return createGeneralBalance("", bal: bal, name: "WAVES")
    }
    
    class func addGeneralBalance(_ id: String, _ name: String) {
        let realm = try! Realm()

        let existing = realm.object(ofType: AssetBalance.self, forPrimaryKey: id)
        
        if existing == nil {
            let ab = createGeneralBalance(id, bal: 0, name: name)
            try! realm.write {
                realm.add(ab, update: true)
            }
        }
    }
    
    class func addGeneralBalances() {
        Environments.current.generalAssetIds.forEach{ addGeneralBalance($0.assetId, $0.displayName) }
    }
    
    /*class func getGeneralBalances() -> [AssetBalance] {
        var generalAssets = [AssetBalance]()
        for a in Environments.current.generalAssetIds {
            generalAssets.append(createGeneralBalance(a.assetId, bal: 0, name: a.name, quantity: a.quantity, decimals: Int16(a.decimals)))
        }
        return generalAssets
    }*/
    

    
    class func broadcastTransfer(transferRequest: TransferRequest) -> Observable<TransferTransaction> {
        let u = Environments.current.servers.nodeUrl.appendingPathComponent("/assets/broadcast/transfer")
        return RxAlamofire.requestJSON(.post, u,
                                       parameters: transferRequest.toJSON(), encoding: JSONEncoding.default)
            .flatMap { (resp, json) -> Observable<TransferTransaction> in
                print(resp)
                if let res = json as? JSON {
                    if let tx = TransferTransaction(json: res) {
                        return Observable.just(tx)
                    } else {
                        print(res)
                        return Observable.error(ApiError.ServerError(res.description))
                    }
                } else {
                    return Observable.error(ApiError.IncorrectResponseFormat)
                }
        }
    }
    
}
