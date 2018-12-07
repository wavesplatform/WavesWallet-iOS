//
//  CameraAccess.swift
//  WavesWallet-iOS
//
//  Created by Mac on 25/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraAccess {
    
    static var alertController: UIAlertController = {
        let alert = UIAlertController(
            title: Localizable.Waves.Cameraaccess.Alert.title,
            message: Localizable.Waves.Cameraaccess.Alert.message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: Localizable.Waves.Cameraaccess.Alert.cancel, style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: Localizable.Waves.Cameraaccess.Alert.allow, style: .default, handler: { (alert) -> Void in
            
            if #available(iOS 10.0, *) {
                
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                
            }
        }))
        
        return alert
    }()
    
    static func requestAccess(success: (() -> Void)?, failure: (() -> Void)?) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined: CameraAccess.requestCameraPermission { (isSuccess) in
                if isSuccess {
                    success?()
                } else {
                    failure?()
                }
            }
            case .authorized: success?()
            case .restricted, .denied: failure?()
        }
    }
    
    static func requestCameraPermission(completion: @escaping ((Bool) -> Void)) {
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { accessGranted in
            DispatchQueue.main.async {
                completion(accessGranted)
            }
        })
        
    }
    
}
