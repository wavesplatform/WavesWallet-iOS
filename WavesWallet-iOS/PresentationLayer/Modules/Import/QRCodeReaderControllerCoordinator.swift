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

        CameraAccess.requestAccess(success: { [weak self] in
            guard let owner = self else { return }
            owner.readerVC.completionBlock = completionBlock
            owner.readerVC.modalPresentationStyle = .formSheet
            owner.rootViewController.present(owner.readerVC, animated: true)
        }, failure: { [weak self] in
            let alert = CameraAccess.alertController
            self?.rootViewController.present(alert, animated: true, completion: nil)
        })
    }
    
    // --
    
    lazy var readerVC: QRCodeReaderViewController = QRCodeReaderFactory.deffaultCodeReader
}
