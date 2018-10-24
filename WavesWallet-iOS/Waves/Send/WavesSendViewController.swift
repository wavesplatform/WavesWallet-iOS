//
//  WavesSendViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader
import TTTAttributedLabel
import MessageUI


class WavesSendViewController: BaseAmountViewController, UIScrollViewDelegate, TTTAttributedLabelDelegate, MFMailComposeViewControllerDelegate {

    var hideTabBarOnBack = false
    
    @IBOutlet weak var viewAssetName: UIView!
    @IBOutlet weak var viewReceipt: UIView!
    @IBOutlet weak var buttonDeleteReceipt: UIButton!
    @IBOutlet weak var buttonScanner: UIButton!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewReceipt: UIScrollView!
    @IBOutlet weak var heightScrollViewReceipt: NSLayoutConstraint!
    @IBOutlet weak var textFieldReceipt: UITextField!
    @IBOutlet weak var arrowChangeAsset: UIImageView!
    @IBOutlet weak var labelAssetValue: UILabel!
    @IBOutlet weak var iconFavAsset: UIImageView!
    @IBOutlet weak var labelAsset: UILabel!
    @IBOutlet weak var imageIconAsset: UIImageView!
    @IBOutlet weak var labelSelectYourAsset: UILabel!
    @IBOutlet weak var labelAssetCryptoName: UILabel!
    
    
    @IBOutlet weak var scrollViewAddressConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewInfoAssetConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewTopSeparator: UIView!
    @IBOutlet weak var labelTitleSmall: UILabel!
    @IBOutlet weak var labelTitleBig: UILabel!
    @IBOutlet weak var labelAddressInvaliedError: UILabel!
    @IBOutlet weak var labelAmountError: UILabel!
    
    let receiptAddreses = ["Choose from Address book", "Withdraw to bank", "Mike Node", "Roman", "Peter Ivanov"]

    @IBOutlet weak var viewAssetInfo: UIView!
    @IBOutlet weak var viewFiatInfo: UIView!
    @IBOutlet weak var viewFiatInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelFiatInfoWarning: TTTAttributedLabel!
    @IBOutlet weak var labelFiatInfoAmount: TTTAttributedLabel!
    @IBOutlet weak var labelAssetInfoFee: UILabel!
    @IBOutlet weak var labelAssetInfoAmount: UILabel!
    @IBOutlet weak var labelAssetInfoWarning: UILabel!
    
    var isValidAmount = false
    var selectedAsset : String = ""
    var isUseFiatAsset = false
    var isUseFiatBank = false
    var isValidAddress = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        title = "Send"
        navigationController?.setNavigationBarHidden(true, animated: true)

        viewAssetName.addTableCellShadowStyle()
        viewReceipt.addTableCellShadowStyle()
        
        setupBigNavigationBar()
    
        buttonDeleteReceipt.alpha = 0
        setupScrollReceiptAddress()
        setupButtonContinue()
        setupAssetState()
        viewAssetInfo.alpha = 0
        viewFiatInfo.alpha = 0
        labelTitleSmall.isHidden = true
        
        setupStyleLabelFiatInfo()
       
        labelAddressInvaliedError.isHidden = true
        labelAmountError.isHidden = true
    }
  
    func setupStyleLabelFiatInfo() {
        var params = [kCTUnderlineStyleAttributeName as String : true,
                      kCTForegroundColorAttributeName as String : UIColor.black.cgColor] as [String : Any]
        
        labelFiatInfoWarning.linkAttributes = params
        labelFiatInfoWarning.inactiveLinkAttributes = params
        labelFiatInfoAmount.linkAttributes = params
        labelFiatInfoAmount.inactiveLinkAttributes = params
        
        params[kCTForegroundColorAttributeName as String] = UIColor(130, 130, 130).cgColor
        labelFiatInfoWarning.activeLinkAttributes = params
        labelFiatInfoWarning.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelFiatInfoWarning.delegate = self
        labelFiatInfoAmount.activeLinkAttributes = params
        labelFiatInfoAmount.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelFiatInfoAmount.delegate = self

        var attr = NSMutableAttributedString(string: "If you have been verified and have deposited US dollars, you can withdraw these dollars back to your bank account. Otherwise, get verified by our partner IDNow.eu", attributes: [NSAttributedStringKey.font : labelFiatInfoWarning.font])
        labelFiatInfoWarning.setText(attr)
        
        attr = NSMutableAttributedString(string: "The minimum amount is 500 US Dollar. If you have any questions, please just send an email to support@coinomat.com", attributes: [NSAttributedStringKey.font : labelFiatInfoAmount.font])
        labelFiatInfoAmount.setText(attr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if !hideTabBarOnBack {
//            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func setupAssetState() {
       
        let isSelectAsset = selectedAsset.count > 0
        labelAssetValue.isHidden = !isSelectAsset
        iconFavAsset.isHidden = !isSelectAsset
        labelAsset.isHidden = !isSelectAsset
        imageIconAsset.isHidden = !isSelectAsset
        labelAssetCryptoName.isHidden = !isSelectAsset
        labelSelectYourAsset.isHidden = isSelectAsset
        
        if isSelectAsset {
            labelAsset.text = selectedAsset
            let iconTitle = DataManager.logoForCryptoCurrency(selectedAsset)
            if iconTitle.count == 0 {
                imageIconAsset.image = nil
                labelAssetCryptoName.text = String(selectedAsset.first!).uppercased()
                imageIconAsset.backgroundColor = DataManager.bgColorForCryptoCurrency(selectedAsset)
            }
            else {
                labelAssetCryptoName.text = nil
                imageIconAsset.image = UIImage(named: iconTitle)
            }
        }
    }
    
    @IBAction func chooseAsset(_ sender: Any) {

    }
    
    @IBAction func continueTapped(_ sender: Any) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "WavesSendConfirmationViewController") as! WavesSendConfirmationViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clearRecipientText() {

        setupValidAddressState()
        
        textFieldReceipt.text = nil
        heightScrollViewReceipt.constant = 30
        textFieldReceipt.isEnabled = true
        UIView.animate(withDuration: 0.3) {
            
            self.viewAssetInfo.alpha = self.isCoinAsset ? 1 : 0
            self.viewFiatInfo.alpha = self.isUseFiatBank ? 1 : 0

            self.buttonScanner.alpha = 1
            self.buttonDeleteReceipt.alpha = 0
            self.scrollViewReceipt.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        setupButtonContinue()
    }
    
    @IBAction func deleteRecepintAddressTapped(_ sender: Any) {
        
        if isCoinAsset {
            selectedAsset = ""
            setupAssetState()
            setupDefaultPriority()
        }
        
        if isUseFiatBank {
            setupDefaultPriority()
            isUseFiatBank = false
        }
        
        clearRecipientText()
    }
    
    override func amountTapped(_ sender: UIButton) {
        super.amountTapped(sender)
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value > 0 {
                isValidAmount = true
            }
        }
        
        setupButtonContinue()
    }
    
    override func amountChange() {
        super.amountChange()
        
        isValidAmount = false
        if let value = Double(textFieldAmount.text!) {
            if value > 0 {
                isValidAmount = true
            }
        }
        
        setupButtonContinue()
    }
    
    func setupButtonContinue() {
        if isValidAmount && isValidAddress && textFieldReceipt.text!.count > 0 {
            buttonContinue.setupButtonActiveState()
        }
        else {
            buttonContinue.setupButtonDeactivateState()
        }
    }
    
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    @IBAction func scanTapped(_ sender: Any) {
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
            
            if let address = result?.value {
                self.textFieldReceipt.text = address
                self.updateRecipientAddressFillState()
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showSmallTitle = scrollView.contentOffset.y >= 30
        
        if showSmallTitle {
            viewTopSeparator.isHidden = false
            labelTitleBig.isHidden = true
            labelTitleSmall.isHidden = false
        }
        else {
            viewTopSeparator.isHidden = true
            labelTitleBig.isHidden = false
            labelTitleSmall.isHidden = true
        }
    }
    
    func updateRecipientAddressFillState() {
        heightScrollViewReceipt.constant = 0
        textFieldReceipt.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            
            self.viewAssetInfo.alpha = self.isCoinAsset ? 1 : 0
            self.viewFiatInfo.alpha = self.isUseFiatBank ? 1 : 0

            self.buttonScanner.alpha = 0
            self.buttonDeleteReceipt.alpha = 1
            self.scrollViewReceipt.alpha = 0
            self.view.layoutIfNeeded()
        }
        
        setupButtonContinue()
    }
    
    @objc func addresesTapped(_ sender: UIButton) {
        
        let index = sender.tag
        
        if index == 0 {
            
//            let vc = AddressBookModuleBuilder(output: self).build(input: .init(isEditMode: false))
//            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            
            if isUseFiatAsset && index == 1 {
                textFieldReceipt.text = "Bank account"
                isUseFiatBank = true
                setupFiatInfoPriority()
                updateRecipientAddressFillState()
            }
            else {
                let value = receiptAddreses[index]
                textFieldReceipt.text = value
                updateRecipientAddressFillState()
            }
        }
    }
    
    func setupScrollReceiptAddress() {
        
        for view in scrollViewReceipt.subviews {
            view.removeFromSuperview()
        }
        
        let offset : CGFloat = 8
        
        var scrollWidth : CGFloat = 0
        for (index, value) in receiptAddreses.enumerated() {
            
            if !isUseFiatAsset && index == 1 {
                continue
            }
            
            let button = ScrollButton(title: value)
            button.addTarget(self, action: #selector(addresesTapped(_:)), for: .touchUpInside)
            button.tag = index
            button.frame.origin.x = scrollWidth
            scrollViewReceipt.addSubview(button)
            scrollWidth += button.frame.size.width + offset
        }
        scrollViewReceipt.contentSize.width = scrollWidth + offset
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {

        if (url.relativeString as NSString).range(of: "@").location != NSNotFound {
            
            if MFMailComposeViewController.canSendMail() {
                let toRecepient = (url.relativeString as NSString).replacingOccurrences(of: "mailto:", with: "")
                let controller = MFMailComposeViewController()
                controller.mailComposeDelegate = self
                controller.setToRecipients([toRecepient])
                present(controller, animated: true, completion: nil)
            }
        }
        else {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK: - ChooseAssetViewControllerDelegate
    
    func setupDefaultPriority() {
        viewInfoAssetConstraint.priority = UILayoutPriority(rawValue: 749)
        scrollViewAddressConstraint.priority = UILayoutPriority(rawValue: 750)
        viewFiatInfoConstraint.priority = UILayoutPriority(rawValue: 748)
    }
    
    func setupAssetInfoPriority() {
        viewInfoAssetConstraint.priority = UILayoutPriority(rawValue: 750)
        scrollViewAddressConstraint.priority = UILayoutPriority(rawValue: 749)
        viewFiatInfoConstraint.priority = UILayoutPriority(rawValue: 748)
    }
    
    func setupFiatInfoPriority() {
        viewInfoAssetConstraint.priority = UILayoutPriority(rawValue: 749)
        scrollViewAddressConstraint.priority = UILayoutPriority(rawValue: 748)
        viewFiatInfoConstraint.priority = UILayoutPriority(rawValue: 750)
    }
    
    var isCoinAsset: Bool {
        return selectedAsset.lowercased() != "usd" &&
            selectedAsset.lowercased() != "eur" &&
            selectedAsset.lowercased() != "waves" &&
            selectedAsset.count > 0
    }
    
    func setupInvalidAddressState() {
        isValidAddress = false
        labelAddressInvaliedError.isHidden = false
    }
    
    func setupValidAddressState() {
        isValidAddress = true
        labelAddressInvaliedError.isHidden = true
    }
    
    
    func chooseAssetViewControllerDidSelectAsset(_ asset: String) {
        selectedAsset = asset
        setupAssetState()

        viewAssetInfo.alpha = 0
        viewFiatInfo.alpha = 0
        isUseFiatAsset = false
        isUseFiatBank = false

        if selectedAsset.lowercased() == "usd" || selectedAsset.lowercased() == "eur" {
            isUseFiatAsset = true
            setupDefaultPriority()
            clearRecipientText()
        }
        else if selectedAsset.lowercased() == "waves" {
            setupDefaultPriority()
            clearRecipientText()
        }
        else {
            
            if selectedAsset.lowercased() == "eth" {
                setupInvalidAddressState()
            }
            else {
                setupValidAddressState()
            }
            
            textFieldReceipt.text = "&some \(asset) address&"
            setupAssetInfoPriority()
            updateRecipientAddressFillState()
        }
        
        setupScrollReceiptAddress()
        setupLabelsAssetInfo()
    }
  
    func setupLabelsAssetInfo() {
        labelAssetInfoFee.text = "Gateway fee is 0.001 \(selectedAsset)"
        labelAssetInfoAmount.text = "We detected \(selectedAsset) address and will send your money through Coinomat gateway to that address. Minimum amount is 0.001 \(selectedAsset), maximum amount is 20 \(selectedAsset)."
        labelAssetInfoWarning.text = "Do not withdraw \(selectedAsset) to an ICO. We will not credit your account with tokens from that sale."
    }
    
    deinit {
        print(self.classForCoder, #function)
    }
    
}

//MARK: - AddressBookModuleOutput
extension WavesSendViewController: AddressBookModuleOutput {
   
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        textFieldReceipt.text = contact.address
        updateRecipientAddressFillState()
    }
}
