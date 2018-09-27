import UIKit
import UILabel_Copyable


class AssetPairDetailsViewController: UITableViewController, HalfModalPresentable {

    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var amountAssetLabel: UILabel!
    @IBOutlet weak var amountAssetNameLabel: UILabel!
    
    @IBOutlet weak var priceAssetLabel: UILabel!
    @IBOutlet weak var priceAssetNameLabel: UILabel!

    var item: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
    }
    
    @IBAction func onMaximize(_ sender: Any) {
        maximizeToFullScreen()
    }
    
    @IBAction func onClose(_ sender: Any) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setupFields() {
        headerTitleLabel.text = "Asset Pair Details"
        tickerLabel.text = DataManager.shared.getTickersTitle(item: item)
        
        amountAssetLabel.copyingEnabled = true
        amountAssetLabel.text = self.item["amountAsset"] as? String
        amountAssetNameLabel.text = item["amountAssetName"] as? String
        
        priceAssetLabel.copyingEnabled = true
        priceAssetLabel.text = item["priceAsset"] as? String
        priceAssetNameLabel.text = item["priceAssetName"] as? String
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
        
}
