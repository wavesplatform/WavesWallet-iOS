//
//  ReceiveViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 25/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import QRCode

class ReceiveViewController: UITableViewController, UITextFieldDelegate {
//    @IBOutlet weak var amountField: UITextField!
//    @IBOutlet weak var amountErrorLabel: UILabel!
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak var qrCodeImageView: UIImageView!
//    @IBOutlet weak var submitButton: UIButton!
//    
//    var selectedAccount: AssetBalance?
//    let bag = DisposeBag()
//    
////    var selectAccountController: SelectAccountViewController {
////        get {
////            let vc = childViewControllers.first(where: { $0 is SelectAccountViewController })
////            return vc as! SelectAccountViewController
////        }
////    }
//
//    lazy var selectedAsset: Driver<AssetBalance> = {
//        return self.selectAccountController.selectedAccount
//            .asObservable()
//            .flatMap { ab -> Observable<AssetBalance> in
//                if let ab = ab { return Observable.just(ab) }
//                else { return WalletManager.getWavesAssetBalance() }
//            }.asDriver(onErrorJustReturn: AssetBalance())
//    }()
//    
//    lazy var addressDriver: Driver<String> = {
//        return Driver.just(WalletManager.getAddress())
//    }()
//    
//    lazy var unscaled: Driver<String?> = {
//        return Driver.combineLatest(self.selectedAsset, self.amountField.rx.text.orEmpty.asDriver()) {
//            MoneyUtil.parseUnscaled($1, $0.getDecimals()).map{ String($0)}
//        }
//    }()
//
//    lazy var shareUrl: Driver<URL> = {
//        return Driver.combineLatest(self.addressDriver, self.selectedAsset.map{ $0.assetId }, self.unscaled) {
//            OpenUrlManager.createUrl(address: $0, assetId: $1, amount: $2)
//        }.filter{ $0 != nil }.map{ $0! }
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let selectedAccount = selectedAccount {
//            let _ = selectAccountController.selectAccount(assetId: selectedAccount.assetId)
//        }
//        
//        setupAmountField()
//        
//        shareUrl
//            .map{ QRCode($0)?.image }
//            .drive(qrCodeImageView.rx.image)
//            .disposed(by: bag)
//        
//        submitButton.rx.tap.asObservable()
//            .withLatestFrom(shareUrl.asObservable())
//            .subscribe(onNext: { url in
//                let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
//                self.present(vc, animated: true)
//            })
//            .disposed(by: bag)
//        
//        addressDriver.drive(addressLabel.rx.text)
//            .disposed(by: bag)
//        
//        let tap = UITapGestureRecognizer()
//        tap.rx.event.withLatestFrom(addressDriver.asObservable())
//            .subscribe(onNext: { addr in
//                UIPasteboard.general.string = addr
//                self.addressLabel.text = "Copied to Clipboard!"
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                    self.addressLabel.text = addr
//                }
//            })
//            .disposed(by: bag)
//        qrCodeImageView.addGestureRecognizer(tap)
//    }
//    
//    func setupAmountField() {
//        amountField.delegate = self
//        selectedAsset.skip(1)
//            .withLatestFrom(self.amountField.rx.text.orEmpty.asDriver(), resultSelector: { ($0.getDecimals(), $1) })
//            .filter{ !$0.1.isEmpty }
//            .map{ MoneyUtil.formatDecimals(MoneyUtil.parseDecimal($0.1) ?? 0, decimals: $0.0) }
//            .drive(amountField.rx.text)
//            .disposed(by: bag)
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == amountField {
//            return MoneyUtil.shouldChangeAmount(textField, selectAccountController.selectedAccount.value?.getDecimals() ?? 0, range, string)
//        } else {
//            return true
//        }
//    }

}
