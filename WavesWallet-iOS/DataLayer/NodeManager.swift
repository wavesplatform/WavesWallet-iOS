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

