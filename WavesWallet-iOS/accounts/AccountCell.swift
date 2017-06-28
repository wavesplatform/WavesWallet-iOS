import UIKit
import MGSwipeTableCell

class AccountCell: MGSwipeTableCell {

    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var balance: UILabel!
    
    var assetBalance: AssetBalance?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindItem(_ item: AssetBalance) {
        assetBalance = item
        assetName?.text =  item.issueTransaction?.name ?? "Unknown"
        balance?.text = MoneyUtil.getScaledText(item.balance, decimals: Int(item.issueTransaction?.decimals ?? 8))
        
        let hideImage = UIImage(named: item.isHidden ? "unhide" : "hide")
        let hideButton = MGSwipeButton(title: item.isHidden ? "Unhide" : "Hide", icon: hideImage, backgroundColor: AppColors.wavesColor, padding: 40)
        hideButton.tag = Int(item.isHidden ? 1 : 0)
        hideButton.iconTintColor(AppColors.activeColor)
        hideButton.centerIconOverText()
        rightButtons = [hideButton]
        leftSwipeSettings.transition = .drag
        
        if item.isHidden {
            self.backgroundColor = AppColors.lightSectionColor
            self.accessoryType = .none
            self.selectionStyle = .none
        } else {
            self.backgroundColor = UIColor.white
            self.accessoryType = .disclosureIndicator
            self.selectionStyle = .default
        }
    }

}
