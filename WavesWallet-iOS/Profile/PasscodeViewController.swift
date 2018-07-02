//
//  PasscodeViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import AudioToolbox
import LocalAuthentication

class PasscodeViewController: UIViewController {

    
    @IBOutlet var dots: [UIView]!
    @IBOutlet var confirmDots: [UIView]!
    
    let password = "1111"
    var inputPassword = ""
    
    var firstPassword = ""
    var secondPassword = ""
    
    var isInputPassword = true
    var isCreateFirstPassword = false
    var isCreateSecondPassword = false

    @IBOutlet weak var labelEnterPassword: UILabel!
    @IBOutlet weak var viewPassword1: UIView!
    @IBOutlet weak var viewPassword2: UIView!
    
    @IBOutlet weak var viewLeftOffset: NSLayoutConstraint!
    @IBOutlet weak var buttonTouchId: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .white
        setupSmallNavigationBar()
        createBackButton()
        hideTopBarLine()
        setupDots()
        setupConfirmDots()
        
        if Platform.isIphoneX {
            buttonTouchId.setImage(UIImage(named: "faceid48Submit300"), for: .normal)
        }
        
        setupButtonBiometrics()
        if biometricType == .touchID {
            authWithBiometrics(reason: "Authenticate with Touch ID")
        }
        else if biometricType == .faceID {
            authWithBiometrics(reason: "Authenticate with Face ID")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupButtonBiometrics), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func setupButtonBiometrics() {
        buttonTouchId.isHidden = biometricType == .none
    }
    
    func authWithBiometrics(reason: String) {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, errror) in
            
            if success {
                DispatchQueue.main.async {
                    self.buttonTouchId.alpha = 0
                    self.isInputPassword = false
                    self.isCreateFirstPassword = true
                    self.labelEnterPassword.text = "Set passcode"
                    self.setupDots()
                }
            }
        }
    }
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        get {
            let context = LAContext()
            var error: NSError?
            
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return .none
            }
            
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                }
            } else {
                return  .touchID
            }
        }
    }
    
    func setupConfirmDots() {
        for i in 0..<confirmDots.count {
            let view = confirmDots.first(where: {$0.tag == i})!
            if i < secondPassword.count {
                view.backgroundColor = .submit400
            }
            else {
                view.backgroundColor = .basic100
            }
        }
    }
    
    func setupDots() {
        
        let count = isCreateFirstPassword ? firstPassword.count : inputPassword.count
        
        for i in 0..<dots.count {
            let view = dots.first(where: {$0.tag == i})!
            if i < count {
                view.backgroundColor = .submit400
            }
            else {
                view.backgroundColor = .basic100
            }
        }
    }
    
    func showErrorDots() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        let _dots = (isInputPassword || isCreateFirstPassword) ? dots : confirmDots
        for view in _dots! {
            view.backgroundColor = .error400
        }
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for view in _dots! {
                view.backgroundColor = .basic100
            }
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func touchIdTapped(_ sender: Any) {
        if biometricType == .touchID {
            authWithBiometrics(reason: "Authenticate with Touch ID")
        }
        else if biometricType == .faceID {
            authWithBiometrics(reason: "Authenticate with Face ID")
        }
    }
    
    @IBAction func crossTapped(_ sender: Any) {
    
        AudioServicesPlaySystemSound(1105)

        if isInputPassword {
            if inputPassword.count > 0 {
                inputPassword.removeLast()
            }
        }
        else if isCreateSecondPassword {
            if secondPassword.count > 0 {
                secondPassword.removeLast()
            }
        }
        else if isCreateFirstPassword {
            if firstPassword.count > 0 {
                firstPassword.removeLast()
            }
        }
        
        setupDots()
        setupConfirmDots()
    }
    
    @IBAction func numberTapped(_ sender: Any) {
    
        AudioServicesPlaySystemSound(1104)

        let value = (sender as! UIButton).tag
        
        if isInputPassword {
            inputPassword.append(String(value))

            if inputPassword.count >= 4 {
                if inputPassword == password {
                    UIView.animate(withDuration: 0.3) {
                        self.buttonTouchId.alpha = 0
                    }
                    isInputPassword = false
                    isCreateFirstPassword = true
                    labelEnterPassword.text = "Set passcode"
                    setupDots()
                }
                else {
                    inputPassword = ""
                    showErrorDots()
                }
            }
            else {
                setupDots()
            }
        }
        else if isCreateFirstPassword {
            firstPassword.append(String(value))
            if firstPassword.count >= 4 {
                setupDots()
                
                view.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.viewLeftOffset.constant = -Platform.ScreenWidth
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: { (complete) in
                        self.viewPassword1.isHidden = true
                        self.view.isUserInteractionEnabled = true
                    })
                }
                
                isCreateFirstPassword = false
                isCreateSecondPassword = true
            }
            else {
                setupDots()
            }
        }
        else if isCreateSecondPassword {

            secondPassword.append(String(value))

            if secondPassword.count >= 4 {
                if secondPassword == firstPassword {
                    self.setupConfirmDots()
                    self.view.isUserInteractionEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    secondPassword = ""
                    showErrorDots()
                }
            }
            else {
                setupConfirmDots()
            }
        }
    }
    
    @IBAction func useAccountPassword(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "AccountPasswordViewController") as! AccountPasswordViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
