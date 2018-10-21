import Foundation
import RealmSwift
import Realm
import RxDataSources

final class AddressBook: Object, IdentifiableType {
    @objc dynamic var address = ""
    @objc dynamic var name = ""
    
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
