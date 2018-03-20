//
//  CreateNewWalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxGesture
import QRCodeReader
import AVFoundation

class CreateNewWalletViewController: UIViewController {

    @IBOutlet weak var seedTextView: UITextView!
    @IBOutlet weak var seedErrorLabel: UILabel!
    @IBOutlet weak var walletNameField: UITextField!
    @IBOutlet weak var walletNameErrorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var encodedSwitch: UISegmentedControl!
    @IBOutlet weak var encodedView: UIStackView!
    var qrCodeButton: UIBarButtonItem!

    
    var isCreateNew = true
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        if isCreateNew {
            seedTextView.text = WordList.generatePhrase()
            seedTextView.isEditable = false
            self.title = "Create Wallet"
            encodedView.isHidden = true
        } else {
            self.title = "Import Wallet"
            //seedTextView.text = "trial appear battle what fiber hello weasel grunt spare heavy produce beach one friend sad"
            seedTextView.placeholderText = "Enter wallet seed here..."
            qrCodeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "qrcode"), style: .plain, target: self, action: #selector(onScanQrCode(_:)))
            qrCodeButton.tintColor = AppColors.activeColor
            self.navigationItem.rightBarButtonItem = qrCodeButton
            encodedView.isHidden = false
        }

        setupValidations()
        setupSubmit()
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var walletName: Driver<Try<String>> = {
        return self.walletNameField.rx.text.orEmpty.asDriver()
        .map { $0.isEmpty ? Try.Err("Name is required") : Try.Val($0) }
    }()
    
    lazy var isEncoded: Driver<Bool> = {
        return self.encodedSwitch.rx.selectedSegmentIndex.asDriver().map{ $0 == 1 }
    }()
    
    lazy var walletSeedText: Driver<Try<String>> = {
        return self.seedTextView.rx.text.orEmpty.asDriver()
            .map { $0.isEmpty ? Try.Err("Wallet is required") : Try.Val($0) }
    }()
    
    lazy var walletSeed: Driver<Try<[UInt8]>> = {
        return Driver.combineLatest(self.isEncoded, self.walletSeedText) { isEncoded, seed in
            switch seed {
            case .Err(let e): return Try.Err(e)
            case .Val(let s):
                if isEncoded {
                    let decoded = Base58.decode(s)
                    return decoded.count > 0 ? Try.Val(decoded) : Try.Err("Invalid Base58 string")
                } else {
                    return Try.Val(Array(s.utf8))
                }
            }
        }
    }()

    
    lazy var wallet: Driver<Try<WalletItem>> = {
        return Driver.combineLatest(self.walletName, self.walletSeed) {(name, seed) -> Try<WalletItem> in
            if let name = name.toOpt, let seed = seed.toOpt {
                let pk = PrivateKeyAccount(seed: seed)
                let wallet = WalletItem(value: [pk.getPublicKeyStr(), name])
                wallet.publicKey = pk.getPublicKeyStr()
                return Try.Val(wallet)
            } else {
                return Try.Err("Invalid wallet")
            }
        }
    }()
    
    lazy var viewTap: Driver<Bool> = {
        return self.view.rx.tapGesture().when(.recognized).map {_ in true}
            .asDriver(onErrorJustReturn: false)
    }()
    
    lazy var submit: Driver<Bool> = {
        return self.submitButton.rx.tap.asDriver().map {true}
    }()


    func validationResultTextInput<A>(field: UITextField, errorLabel: UILabel, value: Driver<Try<A>>) {
        let fieldDidEnd = field.rx.controlEvent(.editingDidEnd).asDriver().map { true }
        let needValidate = Driver.merge(submit, fieldDidEnd, viewTap)
        Driver
            .combineLatest(needValidate, value) { $0 && $1.exists}
            .drive(errorLabel.rx.isHidden)
            .addDisposableTo(bag)
    }
    
    func validationResultTextView<A>(field: UITextView, errorLabel: UILabel, value: Driver<Try<A>>) {
        let fieldDidEnd = field.rx.didEndEditing.asDriver().map { true }
        let needValidate = Driver.merge(submit, fieldDidEnd, viewTap)
        Driver
            .combineLatest(needValidate, value) { $0 && $1.exists}
            .drive(errorLabel.rx.isHidden)
            .addDisposableTo(bag)
        value.map{ $0.error }
            .drive(errorLabel.rx.text)
            .addDisposableTo(bag)
    }

    
    func setupValidations() {
        validationResultTextInput(field: walletNameField, errorLabel: walletNameErrorLabel, value: walletName)
        validationResultTextView(field: seedTextView, errorLabel: seedErrorLabel, value: walletSeed)
        
        walletName.map { $0.exists }
            .drive(submitButton.rx.isEnabled)
            .addDisposableTo(bag)
    }
    
    func setupSubmit() {
        self.submit.withLatestFrom(Driver.combineLatest(wallet, walletSeed) { ($0, $1) })
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {(w, s) in
                if let w = w.toOpt, let s = s.toOpt {
                    print("setupSubmit \(Thread.current)")
                    WalletManager.createWallet(wallet: w, seedBytes: s)
                }
            })
            .addDisposableTo(bag)
    }
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    @IBAction func onScanQrCode(_ sender: Any) {
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let s = result?.value {
               self.seedTextView.text = s
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)

    }
    
}
