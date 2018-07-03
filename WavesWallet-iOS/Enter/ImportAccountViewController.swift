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

class ImportAccountViewController: UIViewController, TTTAttributedLabelDelegate {

    @IBOutlet weak var labelLog: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        
        title = "Import account"
        navigationController?.navigationBar.barTintColor = .white
        setupBigNavigationBar()
        createBackButton()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        var params = [kCTUnderlineStyleAttributeName as String : true,
                      kCTForegroundColorAttributeName as String : UIColor.black.cgColor] as [String : Any]
        
        labelLog.linkAttributes = params
        labelLog.inactiveLinkAttributes = params
        
        params[kCTForegroundColorAttributeName as String] = UIColor(130, 130, 130).cgColor
        labelLog.activeLinkAttributes = params
        labelLog.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        labelLog.delegate = self
        
        let attr = NSAttributedString(string: "Log in to your Beta Client via your PC or Mac at https://beta.wavesplatform.com", attributes: [NSFontAttributeName : labelLog.font])
        labelLog.setText(attr)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        hideTopBarLine()
    }
    
    @IBAction func enterManuallyTapped(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "ImportWelcomeBackViewController") as! ImportWelcomeBackViewController
        navigationController?.pushViewController(controller, animated: true)
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

            }
            self.dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
    
    //MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        UIApplication.shared.openURL(url)
    }
}
