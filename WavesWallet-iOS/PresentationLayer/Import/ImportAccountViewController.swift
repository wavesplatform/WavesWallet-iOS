//
//  ImportAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import QRCodeReader

protocol ImportAccountViewControllerDelegate: AnyObject {
    func enterManuallyTapped()
    func scanedSeed(_ seed: String)
}

final class ImportAccountViewController: UIViewController, TTTAttributedLabelDelegate {

    @IBOutlet final weak var labelLog: TTTAttributedLabel!
    @IBOutlet final weak var stepOneDetailLabel: UILabel!
    @IBOutlet final weak var stepTwoTitleLabel: UILabel!
    @IBOutlet final weak var scanParringButton: UIButton!
    @IBOutlet final weak var enterSeedButton: UIButton!

    weak var delegate: ImportAccountViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Import.Account.Navigation.title

        stepOneDetailLabel.text = Localizable.Import.Account.Label.Info.Step.One.detail
        stepTwoTitleLabel.text = Localizable.Import.Account.Label.Info.Step.Two.title
        scanParringButton.setTitle(Localizable.Import.Account.Button.Scan.title, for: .normal)
        enterSeedButton.setTitle(Localizable.Import.Account.Button.Enter.title, for: .normal)

        navigationItem.barTintColor = .white
        setupBigNavigationBar()
        createBackButton()
        hideTopBarLine()

        var params = [kCTUnderlineStyleAttributeName as String : true,
                      kCTForegroundColorAttributeName as String : UIColor.black.cgColor] as [String : Any]
        
        labelLog.linkAttributes = params
        labelLog.inactiveLinkAttributes = params
        
        params[kCTForegroundColorAttributeName as String] = UIColor(130, 130, 130).cgColor
        labelLog.activeLinkAttributes = params
        labelLog.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelLog.delegate = self
        
        let attr = NSAttributedString(string: Localizable.Import.Account.Label.Info.Step.One.title, attributes: [NSAttributedStringKey.font : labelLog.font])
        labelLog.setText(attr)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func enterManuallyTapped(_ sender: Any) {
        delegate?.enterManuallyTapped()
    }

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.preferredStatusBarStyle = UIStatusBarStyle.lightContent
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    @IBAction func scanTapped(_ sender: Any) {
    
        guard QRCodeReader.isAvailable() else { return }

        readerVC.completionBlock = { [weak self] (result: QRCodeReaderResult?) in
            if let seed = result?.value {
                self?.delegate?.scanedSeed(seed)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }

        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true) {}
    }
    
    //MARK: - TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}
