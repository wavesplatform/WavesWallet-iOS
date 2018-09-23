import Foundation
import RealmSwift
import Realm
import RxDataSources

class AddressBookOld: Object, IdentifiableType {
    @objc dynamic var address = ""
    @objc dynamic var name: String? = nil
    
    public var identity: String {
        return "\(address)"
    }
    override static func primaryKey() -> String? {
        return "address"
    }
}

func == (lhs: AddressBookOld, rhs: AddressBookOld) -> Bool {
    return lhs.address == rhs.address
}
