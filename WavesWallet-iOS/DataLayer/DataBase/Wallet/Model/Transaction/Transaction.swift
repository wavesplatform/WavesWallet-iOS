import Foundation
import Realm
import RealmSwift

public class Transaction: Object {
    public typealias Identity = String

    @objc dynamic var type: Int = 0
    @objc dynamic var id: String = ""
    @objc dynamic var sender: String = ""
    @objc dynamic var senderPublicKey: String = ""
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var height: Int64 = 0
    @objc dynamic var version: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var modified: Date = Date()

    @objc dynamic var isPending: Bool = false

    public override class func primaryKey() -> String? {
        return "id"
    }
}
