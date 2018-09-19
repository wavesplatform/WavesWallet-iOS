//
//  UseTouchIDViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import LocalAuthentication


class UseTouchIDViewController: UIViewController {

    @IBOutlet weak var topLogoOffset: NSLayoutConstraint!
    
    @IBOutlet weak var iconTouch: UIImageView!
    @IBOutlet weak var labelTouchId: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonUseTouchId: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        if Platform.isIphone5 {
            topLogoOffset.constant = 134
        } else if BiometricManager.type == .faceID {
            iconTouch.image = UIImage(named: "faceid48Submit300")
            labelTouchId.text = "Use Face ID to sign in?"
            labelDescription.text = "Use your Face ID for faster, easier access to your account"
            buttonUseTouchId.setTitle("Use Face ID", for: .normal)
        }
    }

    func setupCenterController() {
        AppDelegate.shared().menuController.setContentViewController(MainTabBarController(), animated: true)
    }
    
    @IBAction func useTouchIdTapped(_ sender: Any) {

        if BiometricManager.type != .none {
            DataManager.setUseTouchID(true)
            setupCenterController()
        }
        else {
            presentBasicAlertWithTitle(title: "Please setup your \(BiometricManager.touchIDTypeText)")
        }
    }
    
    @IBAction func notNowTapped(_ sender: Any) {
        DataManager.setUseTouchID(false)
        setupCenterController()
    }
    
}
