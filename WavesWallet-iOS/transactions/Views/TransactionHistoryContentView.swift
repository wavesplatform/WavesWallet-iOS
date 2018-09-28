//
//  TransactionContentView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu


class TransactionHistoryContentView: UIView, TransactionHistoryAddressViewDelegate, AddAddressViewControllerDelegate {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var addressHeight: NSLayoutConstraint!
    @IBOutlet weak var addressContainer: UIView!
    
    var massSentFullHeight: CGFloat = 0
    
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var addressContentBottomOffset: NSLayoutConstraint!
    
    @IBOutlet weak var viewSpam: UIView!
    @IBOutlet weak var viewAssetType: UIView!
    
    
    enum TransactionStatus : String {
        case activeNow = "ACTIVE NOW"
        case unconfirmed = "UNCONFIRMED"
        case completed = "COMPLETED"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Platform.isIphoneX {
            bottomHeight.constant = 85
        }
        
        buttonAction.tintColor = UIColor.white
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
   
    @objc func showAllAddresses() {
        
        let showAllView = addressContainer.subviews.first(where: {$0.isKind(of: TransactionHistoryShowAllView.classForCoder())})
        
        addressHeight.constant = massSentFullHeight
        UIView.animate(withDuration: 0.3, animations: {
            showAllView?.alpha = 0
            self.layoutIfNeeded()
        }) { (complete) in
            showAllView?.removeFromSuperview()
        }
    }
    
    
    func setup(_ item: NSDictionary) {
        var value = ""
        if let val = item["value"] as? Double {
            value = String(val)
        }
        else if let val = item["value"] as? Int {
            value = String(val)
        }
        
        let state = HistoryTransactionState(rawValue: item["state"] as! Int)!
        
        imageViewIcon.image = UIImage(named: HistoryTransactionImages[state.rawValue])
        labelValue.attributedText = NSAttributedString.styleForBalance(text: value, font: labelValue.font)
        
        for view in addressContainer.subviews {
            view.removeFromSuperview()
        }
        
        viewSpam.isHidden = true
        viewAssetType.isHidden = false
        
        let status = item["status"] as! Int
        if status == 0 {
            viewSpam.isHidden = false
            viewAssetType.isHidden = true
            
            labelStatus.text = TransactionStatus.activeNow.rawValue
            labelStatus.textColor = .success500
            viewStatus.backgroundColor = UIColor(red: 74.0 / 255.0, green: 173.0 / 255.0, blue: 2.0 / 255.0, alpha: 0.1)
        }
        else if status == 1 {
            labelStatus.text = TransactionStatus.completed.rawValue
            labelStatus.textColor = .success500
            viewStatus.backgroundColor = UIColor(red: 74.0 / 255.0, green: 173.0 / 255.0, blue: 2.0 / 255.0, alpha: 0.1)
        }
        else if status == 2 {
            labelStatus.text = TransactionStatus.unconfirmed.rawValue
            labelStatus.textColor = .warning600
            viewStatus.backgroundColor = UIColor(red: 248.0 / 255.0, green: 183.0 / 255.0, blue: 0, alpha: 0.1)
        }
        
        if state == .viewSend || state == .massSend || state == .viewLeasing {
            addressContentBottomOffset.constant = 72
            buttonAction.isHidden = false
            
            if state == .viewLeasing {
                buttonAction.setTitle("Cancel leasing", for: .normal)
                buttonAction.setImage(UIImage(named: "tCloselease28"), for: .normal)
                buttonAction.backgroundColor = .error400
            }
            else {
                buttonAction.setTitle("Send again", for: .normal)
                buttonAction.setImage(UIImage(named: "tResend28"), for: .normal)
                buttonAction.backgroundColor = .warning600
            }
        }
        else {
            buttonAction.isHidden = true
            addressContentBottomOffset.constant = 0
        }
        
        if state == .massSend {
            let countAddresses = item["countAddresses"] as! Int
            
            var offset : CGFloat = 0
            massSentFullHeight = 0
            
            for i in 0..<countAddresses {
                
                if i == 0 {
                    let view = TransactionHistoryAddressView.loadView() as! TransactionHistoryAddressView
                    view.delegate = self
                    view.frame.origin.y = offset
                    view.setupInfo(item, showComment: false)
                    addressContainer.addSubview(view)
                    offset += view.frame.size.height
                    massSentFullHeight += view.frame.size.height
                }
                else {
                    let view = TransactionHistoryMassSendView.loadView() as! TransactionHistoryMassSendView
                    view.delegate = self
                    view.frame.origin.y = massSentFullHeight
                    view.setupInfo(item, showComment: i == countAddresses - 1)
                    addressContainer.addSubview(view)
                    if i < 3 {
                        offset += view.frame.size.height
                    }
                    massSentFullHeight += view.frame.size.height
                }
            }
            
            if countAddresses > 3 {
                let view = TransactionHistoryShowAllView.loadView() as! TransactionHistoryShowAllView
                view.buttonShow.addTarget(self, action: #selector(showAllAddresses), for: .touchUpInside)
                view.buttonShow.setTitle("Show all (\(countAddresses))", for: .normal)
                view.frame.origin.y = offset
                view.setupInfo(item)
                addressContainer.addSubview(view)
                offset += view.frame.size.height
            }
            addressHeight.constant = offset
        }
        else {
            
            let view = TransactionHistoryAddressView.loadView() as! TransactionHistoryAddressView
            view.delegate = self
            view.setupInfo(item, showComment: true)
            addressContainer.addSubview(view)
            addressHeight.constant = view.frame.size.height
        }
    }
    
    func addAddressViewControllerDidBack() {
        if let popup = firstAvailableViewController().parent as? PopupViewController {
            popup.showView()
        }
    }
    
    //MARK: - TransactionHistoryAddressViewDelegate
    
    func transactionHistoryAddressViewChangeName(_ item: NSDictionary, isAddMode: Bool) {
                
        if let popup = firstAvailableViewController().parent as? PopupViewController {
            popup.hideView()
        }
        
        let changeNameController = StoryboardManager.TransactionsStoryboard().instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewControllerOlds
        changeNameController.isAddMode = isAddMode
        changeNameController.delegate = self
        changeNameController.showTabBarOnBack = true
        
        let menu = AppDelegate.shared().menuController
        let mainTabBar = menu.contentViewController as! MainTabBarController
        mainTabBar.setupLastScrollCorrectOffset()
        let nav = mainTabBar.selectedViewController as! UINavigationController
        nav.pushViewController(changeNameController, animated: true)
        mainTabBar.setTabBarHidden(true, animated: true)
    }
    
    
}
