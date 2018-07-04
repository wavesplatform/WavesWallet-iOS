import Foundation
import Gloss
import RealmSwift
import Realm
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
    
    required public init() {
        super.init()
    }
    
    override public class func primaryKey() -> String? {
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

public class BasicTransaction: Object, IdentifiableType {
    @objc dynamic var id = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var sender = ""
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var assetId: String = ""
    @objc dynamic var asset: IssueTransaction?
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var isInput = false
    @objc dynamic var addressBook: AddressBook?
    @objc dynamic var counterParty = ""
    @objc dynamic var isPending: Bool = false
    
    convenience init(tx: Transaction) {
        self.init()
        id = tx.id
        type = tx.type
        sender = tx.sender
        timestamp = tx.timestamp
        fee = tx.fee
        assetId = tx.getAssetId()
        let realm = try! Realm()
        asset = realm.object(ofType: IssueTransaction.self, forPrimaryKey: assetId)
        amount = tx.getAmount()
        isInput = tx.isInput()
        counterParty = tx.getCounterParty()
        isPending = tx.isPending
    }
    
    public var identity: String {
        return "\(id)"
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
// equatable, this is needed to detect changes
func == (lhs: BasicTransaction, rhs: BasicTransaction) -> Bool {
    return lhs.id == rhs.id
}

public class TransferTransaction: Transaction {
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var assetId: String?
    @objc dynamic var recipient: String = ""
    @objc dynamic var attachment: String?
    
    public required init?(json: JSON) {
        guard let amount: Int64 = "amount" <~~ json,
            let recipient: String = "recipient" <~~ json else {
                return nil
        }
        
        self.amount = amount
        self.assetId = "assetId" <~~ json
        self.recipient = recipient
        self.attachment = "attachment" <~~ json
        
        super.init(json: json)
    }
    
    required public init() {
        super.init()
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
    
    public override func getAssetId() -> String {
        return assetId ?? ""
    }
    
    public override func getAmount() -> Int64 {
        return amount
    }
    
    public override func getCounterParty() -> String {
        return isInput() ? sender : recipient
    }
}

public class IssueTransaction: Transaction {
    @objc dynamic var name = ""
    @objc dynamic var assetDescription: String?
    @objc dynamic var quantity: Int64 = 0
    @objc dynamic var decimals: Int16 = 0
    @objc dynamic var reissuable = false
    
    public required init?(json: JSON) {
        guard let name: String = "name" <~~ json
            , let quantity: Int64 = "quantity" <~~ json
            , let decimals: Int16 = "decimals" <~~ json
            , let reissuable: Bool = "reissuable" <~~ json else {
                return nil
        }
        
        self.name = name
        self.assetDescription = "description" <~~ json
        self.quantity = quantity
        self.decimals = decimals
        self.reissuable = reissuable
        
        super.init(json: json)
    }
    
    required public init() {
        super.init()
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
    
    public override func getAssetId() -> String {
        return id
    }
    
    public override func getAmount() -> Int64 {
        return quantity
    }
}


public class ExchangeTransaction: Transaction {
    @objc dynamic var sellSender = ""
    @objc dynamic var buySender = ""
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var price: Int64 = 0
    @objc dynamic var amountAsset = ""
    @objc dynamic var priceAsset = ""
    
    
    public required init?(json: JSON) {
        guard let sellSender: String = "order2.senderPublicKey" <~~ json
              , let buySender: String = "order1.senderPublicKey" <~~ json
              , let price: Int64 = "price" <~~ json
              , let amount: Int64 = "amount" <~~ json else {
                return nil
        }
        
        self.sellSender = sellSender
        self.buySender = buySender
        self.price = price
        self.amount = amount
        self.amountAsset = ("order1.assetPair.amountAsset" <~~ json) ?? ""
        self.priceAsset = ("order1.assetPair.priceAsset" <~~ json) ?? ""

        super.init(json: json)
    }
    
    required public init() {
        super.init()
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
    
    public override func getAssetId() -> String {
        return amountAsset
    }
    
    public override func getAmount() -> Int64 {
        return amount
    }
    
    public override func isInput() -> Bool {
        return buyerAddress == WalletManager.getAddress()
    }
    
    var sellerAddress: String {
        return PublicKeyAccount(publicKey: Base58.decode(sellSender)).address
    }
    
    var buyerAddress: String {
        return PublicKeyAccount(publicKey: Base58.decode(buySender)).address
    }
    
    public override func isOur() -> Bool {
        return sellerAddress == WalletManager.getAddress() || buyerAddress == WalletManager.getAddress()
    }
}
