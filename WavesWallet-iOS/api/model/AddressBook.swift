import Foundation
import RealmSwift
import Realm
import RxDataSources

class AddressBook: Object, IdentifiableType {
    dynamic var address = ""
    dynamic var name: String? = nil
    
    public var identity: String {
        return "\(address)"
    }
    override static func primaryKey() -> String? {
        return "address"
    }
}

func == (lhs: AddressBook, rhs: AddressBook) -> Bool {
    return lhs.address == rhs.address
}
