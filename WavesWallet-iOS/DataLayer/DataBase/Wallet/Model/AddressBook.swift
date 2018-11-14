import Foundation
import RealmSwift

final class AddressBook: Object {    
    @objc dynamic var address = ""
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "address"
    }
}
