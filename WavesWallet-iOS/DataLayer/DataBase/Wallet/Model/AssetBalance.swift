import Foundation
import Realm
import RealmSwift

final class AssetBalance: Object {

    typealias Identity = String

    @objc dynamic var modified: Date = Date()
    @objc dynamic var assetId = ""
    @objc dynamic var balance: Int64 = 0
    @objc dynamic var leasedBalance: Int64 = 0
    @objc dynamic var inOrderBalance: Int64 = 0

    override class func primaryKey() -> String? {
        return "assetId"
    }
}
