import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

enum FavoriteViewState {
    case favourited, notFavourited
}

class TransactionCell: UITableViewCell {

    static let minimalNameLength = 3
    
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var decimalsLabel: UILabel!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var starButton: UIButton!

    weak var parentController: UIViewController!
    
    var currentTransaction: BasicTransaction!
    var isFlashing = false
    
    var disposeBag = DisposeBag()
    
    var favoriteState: FavoriteViewState = .notFavourited {
        didSet {
            if favoriteState == .notFavourited {
                starButton.setImage(#imageLiteral(resourceName: "not_star"), for: .normal)
            } else {
                starButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
            }
        }
    }
    
    func saveAddressBook(_ name: String) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.create(AddressBook.self, value: [currentTransaction.counterParty, name], update: true)
        }
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        if favoriteState == .notFavourited {
            AddressBookManager.askForSaveAddress(parentController: parentController, address: currentTransaction.counterParty)
        } else {
            AddressBookManager.askForDeletion(parentController: parentController, address: currentTransaction.counterParty)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func toggelBlinkAnimation() {
        if currentTransaction.isPending {
            startBlinking()
        } else {
            stopBlinking()
        }
    }
    
    func startBlinking() {
        self.amountView.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.amountView.alpha = 0.2
        }, completion: nil )

        
    }
    
    func stopBlinking() {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.amountView.alpha = 1.0
        }, completion: nil )

    }
    
    func bindItem(_ tx: BasicTransaction, parentController: UIViewController) {
        currentTransaction = tx
        self.parentController = parentController
        timestamp?.text = DateUtil.formatTime(ts: tx.timestamp)
        let amount = MoneyUtil.getScaledPair(tx.amount, Int(tx.asset?.decimals ?? 0))
        let sign = tx.isInput ? "" : "\u{2011}"
        amountLabel.text = sign + amount.0
        decimalsLabel.text = amount.1
        amountView.backgroundColor = tx.isInput ? AppColors.receiveGreen : AppColors.sendRed
        assetName.text = tx.asset?.name
        
        if let addressName = tx.addressBook?.name {
            counterpartyLabel?.text = addressName
            favoriteState = .favourited
        } else {
            counterpartyLabel?.text = "\(tx.counterParty)"
            favoriteState = .notFavourited
        }
        //toggelBlinkAnimation()
    }

}
