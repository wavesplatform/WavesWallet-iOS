//
//  QRCodeReaderCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 08/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader

class QRCodeReaderControllerCoordinator {
    
    private let rootViewController: UIViewController
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func start(completionBlock: @escaping ((QRCodeReaderResult?) -> Void)) {
        guard QRCodeReader.isAvailable() else { return }
        
        readerVC.completionBlock = completionBlock
        readerVC.modalPresentationStyle = .formSheet
        
        rootViewController.present(readerVC, animated: true)
        
    }
    
    // --
    
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
    
}
