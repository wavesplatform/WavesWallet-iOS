//
//  QRCodeReader+Factory.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import QRCodeReader

enum QRCodeReaderFactory {

    static var deffaultCodeReader: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
            $0.preferredStatusBarStyle = .lightContent
        }

        return QRCodeReaderViewController(builder: builder)
    }()
}
