import Foundation
import RealmSwift
import Realm
import RxDataSources

final class AddressBook: Object {
    @objc dynamic var address = ""
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "address"
    }
}

func == (lhs: AddressBook, rhs: AddressBook) -> Bool {
    return lhs.address == rhs.address
}
