import Foundation
import Gloss
import Realm
import RealmSwift
import RxDataSources

public class Transaction: Object, IdentifiableType, Gloss.Decodable {
    public typealias Identity = String

    @objc dynamic var id = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var sender = ""
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var isPending: Bool = false

    public required init?(json: JSON) {
        guard let id: String = "id" <~~ json
            , let type: Int = "type" <~~ json
            , let sender: String = "sender" <~~ json
            , let timestamp: Int64 = "timestamp" <~~ json
            , let fee: Int64 = "fee" <~~ json

        else {
            return nil
        }

        self.id = id
        self.type = type
        self.sender = sender
        self.timestamp = timestamp
        self.fee = fee

        super.init()
    }

    public var identity: String {
        return "\(id)"
    }

    public required init() {
        super.init()
    }

    public override class func primaryKey() -> String? {
        return "id"
    }

    public func getAssetId() -> String {
        return ""
    }

    public func getAmount() -> Int64 {
        return 0
    }

    public func isInput() -> Bool {
        return sender != WalletManager.getAddress()
    }

    public func getCounterParty() -> String {
        return sender
    }

    public func isOur() -> Bool {
        return sender == WalletManager.getAddress() || getCounterParty() == WalletManager.getAddress()
    }

    /**
     WARNING: This is an internal initializer not intended for public use.
     :nodoc:
     */
    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    public required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}

// equatable, this is needed to detect changes
func == (lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.id == rhs.id
}
