import Foundation
import Gloss
import RealmSwift
import Realm
import RxDataSources

class AssetBalance
    : Object
    , IdentifiableType
    , Gloss.Decodable {
    
    typealias Identity = String
    
    @objc dynamic var assetId = ""
    @objc dynamic var balance: Int64 = 0
    @objc dynamic var quantity: Int64 = 0
    @objc dynamic var reissuable = false
    @objc dynamic var issueTransaction: IssueTransaction?
    @objc dynamic var isGeneral = false
    @objc dynamic var isHidden = false
    
    var identity: String {
        return assetId
    }
    
    /*override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? AssetBalance {
            return assetId == other.assetId && balance == other.balance && isHidden == other.isHidden
        } else {
            return false
        }
    }*/
    
    override class func primaryKey() -> String? {
        return "assetId"
    }
    
    required init() {
        super.init()
    }
    
    required init?(json: JSON) {
        guard let assetId: String = "assetId" <~~ json else {
            return nil
        }
        
        self.assetId = assetId
        self.balance = "balance" <~~ json ?? 0
        self.quantity = "quantity" <~~ json ?? 0
        self.reissuable = "reissuable" <~~ json ?? false
        self.issueTransaction = "issueTransaction" <~~ json
        
        super.init()
    }
    
    func getDecimals() -> Int {
        return Int(issueTransaction?.decimals ?? 0)
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
func == (lhs: AssetBalance, rhs: AssetBalance) -> Bool {
    return lhs.assetId == rhs.assetId && lhs.balance == rhs.balance && lhs.isHidden == rhs.isHidden
}
