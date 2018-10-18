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
