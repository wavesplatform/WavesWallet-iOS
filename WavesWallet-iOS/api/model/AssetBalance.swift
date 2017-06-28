import Foundation
import Gloss
import RealmSwift
import Realm
import RxDataSources

class AssetBalance
    : Object
    , IdentifiableType
    , Decodable {
    
    typealias Identity = String
    
    dynamic var assetId = ""
    dynamic var balance: Int64 = 0
    dynamic var quantity: Int64 = 0
    dynamic var reissuable = false
    dynamic var issueTransaction: IssueTransaction?
    dynamic var isGeneral = false
    dynamic var isHidden = false
    
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
    
    public required init?(json: JSON) {
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
