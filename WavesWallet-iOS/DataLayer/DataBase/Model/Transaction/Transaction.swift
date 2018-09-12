import Foundation
import Gloss
import Realm
import RealmSwift
import RxDataSources

public class Transaction: Object, IdentifiableType, Gloss.Decodable {
    public typealias Identity = String

    @objc dynamic var type: Int = 0
    @objc dynamic var id: String = ""
    @objc dynamic var sender: String = ""
    @objc dynamic var senderPublicKey: String = ""
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var height: Int64 = 0
    @objc dynamic var version: Int = 0
    @objc dynamic var modified: Date = Date()

    @objc dynamic var isPending: Bool = false

    @available(*, deprecated, message: "need remove")
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

    @available(*, deprecated, message: "need remove")
    public var identity: String {
        return "\(id)"
    }

    public required init() {
        super.init()
    }

    public override class func primaryKey() -> String? {
        return "id"
    }

    @available(*, deprecated, message: "need remove")
    public func getAssetId() -> String {
        return ""
    }

    @available(*, deprecated, message: "need remove")
    public func getAmount() -> Int64 {
        return 0
    }

    @available(*, deprecated, message: "need remove")
    public func isInput() -> Bool {
        return sender != WalletManager.getAddress()
    }

    @available(*, deprecated, message: "need remove")
    public func getCounterParty() -> String {
        return sender
    }

    @available(*, deprecated, message: "need remove")
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
