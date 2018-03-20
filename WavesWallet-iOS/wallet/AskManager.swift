//
//  AskManager.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 04/10/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

class AskManager {
    static let minimalPasswordLength = 6
    
    static var askPasswordBag: DisposeBag?
    
    class func askForPassword() -> Observable<String> {
        let alert = UIAlertController(title: "Enter Password", message: "Enter a password to decrypt your seed from the local storage", preferredStyle: .alert)
        
        askPasswordBag = DisposeBag()
        
        return Observable<String>.create {observer -> Disposable in
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let pwd = alert?.textFields?[0].text {
                    observer.onNext(pwd)
                }
                askPasswordBag = nil
            })
            alert.addAction(okAction)
            
            var pwdValid: Observable<Bool>!
            
            alert.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                pwdValid = textField.rx.text.orEmpty.map { $0.characters.count > 0 }
            }
            
            
            pwdValid
                .asDriver(onErrorJustReturn: false)
                .drive(okAction.rx.isEnabled)
                .addDisposableTo(askPasswordBag!)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                askPasswordBag = nil
                observer.onError(WalletError.Generic("Entering password canceled"))
            })
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.present(alert, animated: true)
            
            return Disposables.create()
        }.subscribeOn(MainScheduler.instance)
    }
    
    class func askForSetPassword() -> Observable<String> {
        let alert = UIAlertController(title: "Set Password", message: "Enter a password to encrypt your seed.\n(min 6 characters)", preferredStyle: .alert)
        
        askPasswordBag = DisposeBag()
        
        return Observable<String>.create {observer -> Disposable in
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let pwd = alert?.textFields?[0].text {
                    observer.onNext(pwd)
                } else {
                    observer.onError(WalletError.Generic("Incorrect password"))
                }
            })
            alert.addAction(okAction)
            
            var pwdValid: Observable<Bool>!
            var pwdText: Observable<String>!
            var repeatValid: Observable<Bool>!
            
            alert.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                pwdText = textField.rx.text.orEmpty.asObservable()
                pwdValid = pwdText?.map { $0.characters.count >= minimalPasswordLength }
            }
            
            alert.addTextField { (textField) in
                textField.placeholder = "Repeat Password"
                textField.isSecureTextEntry = true
                repeatValid = Observable.combineLatest(pwdText, textField.rx.text.orEmpty.asObservable()) { $0 == $1 }
            }
            
            Observable.combineLatest(pwdValid, repeatValid) { $0 && $1 }
                .asDriver(onErrorJustReturn: false)
                .drive(okAction.rx.isEnabled)
                .addDisposableTo(askPasswordBag!)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                askPasswordBag = nil
                observer.onError(WalletError.Generic("Entering password canceled"))
            })
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.present(alert, animated: true)
            
            return Disposables.create()
        }.subscribeOn(MainScheduler.instance)
    }
    
    class func presentBasicAlertWithTitle(title: String, message: String? = nil,
                                           completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            
            if let completion = completion {
                completion()
            }
        }))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.present(alert, animated: true)
    }
  
}
