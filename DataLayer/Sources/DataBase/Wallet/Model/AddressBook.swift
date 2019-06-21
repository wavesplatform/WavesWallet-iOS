import Foundation
import RealmSwift

final class AddressBook: Object {    
    @objc dynamic var address: String = ""
    @objc dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "address"
    }
}
