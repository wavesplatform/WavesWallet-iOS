//
//  WavesReceiveBankViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import MessageUI

class WavesReceiveBankViewController: UIViewController, TTTAttributedLabelDelegate, MFMailComposeViewControllerDelegate, WavesReceiveRedirectViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var verifiedHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notVerifiedHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewNotVerified: UIView!
    @IBOutlet weak var viewVerified: UIView!
    @IBOutlet weak var labelStep1: TTTAttributedLabel!
    @IBOutlet weak var labelSupportNotVerified: TTTAttributedLabel!
    @IBOutlet weak var labelSupportVerified: TTTAttributedLabel!
    
    var isVerified = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
        setupVerifiedState()
    }

    
    @IBAction func verifiedTapped(_ sender: Any) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "WavesReceiveRedirectViewController") as! WavesReceiveRedirectViewController
        controller.isBankMode = true
        controller.delegate = self
        controller.showInController(view.superview!.firstAvailableViewController())
    }
    
    //MARK: - WavesReceiveRedirectViewControllerDelegate
    
    func wavesReceiveRedirectViewControllerDidTapOkey() {
        
        isVerified = true
        setupVerifiedState()
        
        if let controller = view.superview?.firstAvailableViewController() as? WavesReceiveViewController {
            view.frame.size.height = controller.defaultContentControllerHeight
        }
        view.layoutIfNeeded()
        
        if let controller = view.superview?.firstAvailableViewController() as? WavesReceiveViewController {
            controller.setupScrollHeight()
            UIView.animate(withDuration: 0.3) {
                controller.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - Other
    
    func setupVerifiedState() {
        
        if isVerified {
            viewVerified.isHidden = false
            viewNotVerified.isHidden = true
            verifiedHeightConstraint.priority = UILayoutPriority(rawValue: 750)
            notVerifiedHeightConstraint.priority = UILayoutPriority(rawValue: 749)
        }
        else {
            viewVerified.isHidden = true
            viewNotVerified.isHidden = false
            verifiedHeightConstraint.priority = UILayoutPriority(rawValue: 749)
            notVerifiedHeightConstraint.priority = UILayoutPriority(rawValue: 750)
        }
        
    }
    
    
    func setupLabels() {
        var params = [kCTUnderlineStyleAttributeName as String : true,
                      kCTForegroundColorAttributeName as String : UIColor.black.cgColor] as [String : Any]
        
        labelStep1.linkAttributes = params
        labelStep1.inactiveLinkAttributes = params
        labelSupportNotVerified.linkAttributes = params
        labelSupportNotVerified.inactiveLinkAttributes = params
        labelSupportVerified.linkAttributes = params
        labelSupportVerified.inactiveLinkAttributes = params

        params[kCTForegroundColorAttributeName as String] = UIColor(130, 130, 130).cgColor
        labelStep1.activeLinkAttributes = params
        labelStep1.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelStep1.delegate = self

        labelSupportNotVerified.activeLinkAttributes = params
        labelSupportNotVerified.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelSupportNotVerified.delegate = self

        labelSupportVerified.activeLinkAttributes = params
        labelSupportVerified.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelSupportVerified.delegate = self
        
        var attr = NSMutableAttributedString(string: "In order to deposit Euro directly from your bank account through SEPA transfer you must get verified by our partner IDNow.eu",
                                             attributes: [.font : labelStep1.font])
        labelStep1.setText(attr)
        
        
        let text = "In case of problems with verification or payment processing, please contact the Coinomat support team — support@coinomat.com"
        attr = NSMutableAttributedString(string: text, attributes: [.font : labelSupportNotVerified.font,
                                                                    .foregroundColor : UIColor.basic500])
        
        let range = (text as NSString).range(of: "support@coinomat.com")
        attr.addAttributes([.foregroundColor : UIColor.black], range: range)
        labelSupportNotVerified.setText(attr)
        labelSupportVerified.setText(attr)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if scrollView.contentSize.height > view.frame.size.height {
            view.frame.size.height = scrollView.contentSize.height
        }
    }
    
    
    
    @IBAction func listEligibleTapped(_ sender: Any) {
        
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
    
    
    deinit {
        print(classForCoder, #function)
    }
}
