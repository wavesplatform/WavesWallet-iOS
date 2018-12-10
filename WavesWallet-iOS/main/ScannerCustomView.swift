//
//  ScannerCustomView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

final class ScannerCustomView: UIView, QRCodeReaderDisplayable {

    let cameraView: UIView            = UIView()
    let cancelButton: UIButton?       = UIButton()
    let switchCameraButton: UIButton? = SwitchCameraButton()
    let toggleTorchButton: UIButton?  = UIButton()
    var overlayView: UIView?          = UIView()
    
    var reader: QRCodeReader?
    
    var isTorchOn = false
    
    func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool, showOverlayView: Bool, reader: QRCodeReader?) {
        
        addSubview(cameraView)
        
        if let reader = reader {
            self.reader = reader
            cameraView.layer.insertSublayer(reader.previewLayer, at: 0)
        }
        
        if showOverlayView {
            overlayView?.frame = UIScreen.main.bounds
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = overlayView!.bounds
            maskLayer.fillColor = UIColor.black.cgColor

            let path = UIBezierPath(rect: overlayView!.bounds)
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            
            let width : CGFloat = 250
            let cornerRadius: CGFloat = 5
            
            let frame = CGRect(x: (Platform.ScreenWidth - width) / 2, y: (UIScreen.main.bounds.size.height - width) / 2, width: width, height: width)
            path.append(UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius))
            maskLayer.path = path.cgPath
            
            overlayView?.layer.mask = maskLayer
            overlayView?.backgroundColor = UIColor(red: 0.0, green: 26.0 / 255.0, blue: 57.0 / 255.0, alpha: 0.6)
            addSubview(overlayView!)
           
            let maskLayer2 = CAShapeLayer()
            maskLayer2.strokeColor = UIColor.white.cgColor
            maskLayer2.lineWidth = 3
            maskLayer2.lineDashPattern = [3.0, 3.0]
            maskLayer2.lineDashPhase = 0

            let path2 = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
            maskLayer2.path = path2.cgPath
            overlayView?.layer.addSublayer(maskLayer2)
        }
        
        if showCancelButton {
            let buttonWidth : CGFloat = 100
            let buttonHeight : CGFloat = 48
            let offset : CGFloat = Platform.isIphoneX ? 36 : 16
            cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            cancelButton?.frame = CGRect(x: (Platform.ScreenWidth - buttonWidth) / 2, y: UIScreen.main.bounds.size.height - buttonHeight - offset, width: buttonWidth, height: buttonHeight)
            addSubview(cancelButton!)
        }
        
        if showTorchButton {
            toggleTorchButton?.setImage(UIImage(named: "topbarFlashOff"), for: .normal)
            toggleTorchButton?.addTarget(self, action: #selector(changeStateToogle), for: .touchUpInside)
            toggleTorchButton?.frame = CGRect(x: Platform.ScreenWidth - 50, y: Platform.isIphoneX ? 41 : 21, width: 40, height: 40)
            addSubview(toggleTorchButton!)
        }
        
        let labelTitle = UILabel(frame: CGRect(x: 0, y: Platform.isIphoneX ? 50 : 30, width: Platform.ScreenWidth, height: 20))
        labelTitle.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        labelTitle.textAlignment = .center
        labelTitle.textColor = UIColor.white
        labelTitle.text = Localizable.Waves.Scannerqrcode.Label.scan
        addSubview(labelTitle)
    }
    
    @objc func changeStateToogle() {
        isTorchOn = !isTorchOn
        
        if isTorchOn {
            toggleTorchButton?.setImage(UIImage(named: "topbarFlashOn"), for: .normal)
        }
        else {
            toggleTorchButton?.setImage(UIImage(named: "topbarFlashOff"), for: .normal)
        }
    }

    func setNeedsUpdateOrientation() { }
}
