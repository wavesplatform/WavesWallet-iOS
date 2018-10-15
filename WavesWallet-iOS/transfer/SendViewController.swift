//
//  SendViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 26/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import AVFoundation
import QRCodeReader


class SendViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {}
//    @IBOutlet weak var selectAssetView: UIView!
//    @IBOutlet weak var amountField: UITextField!
//    @IBOutlet weak var addressField: UITextField!
//    @IBOutlet weak var useTotalButton: UIButton!
//    @IBOutlet weak var attachmentField: UITextView!
//    @IBOutlet weak var feeField: UITextField!
//    @IBOutlet weak var amountErrorLabel: UILabel!
//    @IBOutlet weak var addressError: UILabel!
//    @IBOutlet weak var feeError: UILabel!
//    @IBOutlet weak var submitButton: UIButton!
//
//    var selectedAccount: AssetBalance?
//    var viewModel: SendViewModel!
//    var openUrl: URL?
//
//    let kMinFee: Int64 = 100000
//
//    var currentDecimals: Int = 0
//    let bag = DisposeBag()
//
////    var selectAccountController: SelectAccountViewController {
////        get {
////            let vc = childViewControllers.first(where: { $0 is SelectAccountViewController })
////            return vc as! SelectAccountViewController
////        }
////    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        if let selectedAccount = selectedAccount {
////            let _ = selectAccountController.selectAccount(assetId: selectedAccount.assetId)
////        }
////
//        setupViewModel()
//
//        setupAddressField()
//        setupAmountField()
//        setupFeeField()
//        setupTotalView()
//        setupAttachementField()
//
//        setupValidations()
//
//        setupSubmit()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenUrl), name:
//            NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
//        handleOpenUrl()
//
//    }
//
////    lazy var selectedAsset: Driver<AssetBalance> = {
////        return self.selectAccountController.selectedAccount
////            .asObservable()
////            .distinctUntilChanged { lhs, rhs -> Bool in return lhs == rhs }
////            .do(onNext: { ab in
////                self.currentDecimals = ab?.getDecimals() ?? 0
////            })
////            .flatMap { ab -> Observable<AssetBalance> in
////                if let ab = ab { return Observable.just(ab) }
////                else { return WalletManager.getWavesAssetBalance() }
////            }
////            .distinctUntilChanged()
////            .asDriver(onErrorJustReturn: AssetBalance())
////    }()
////
//    private func setupViewModel() {
////        viewModel = SendViewModel (
////            input: (
////                addressText: addressField.rx.text.orEmpty.asObservable(),
////                amountText: amountField.rx.text.orEmpty.asObservable(),
////                feeText: feeField.rx.text.orEmpty.asObservable(),
////                attachmentText: attachmentField.rx.text.orEmpty.asObservable()
////            ),
////            dependency: (
////                selectedAsset: self.selectedAsset.asObservable(),
////                wavesBalance: WalletManager.getWavesAssetBalance()
////            )
////        )
//    }
//
//    func setupAddressField() {
//        addressField.delegate = self
//    }
//
//    func setupAmountField() {
//        amountField.delegate = self
//        viewModel.selectedAsset
//            .map{ MoneyUtil.getScaledTextTrimZeros(0, decimals: $0.getDecimals()) }
//            .subscribe(onNext: { self.amountField.placeholder = $0 })
//            .disposed(by: bag)
//
//        viewModel.selectedAsset.skip(1)
//            .withLatestFrom(viewModel.amountText, resultSelector: { ($0.getDecimals(), $1) })
//            .filter{ !$0.1.isEmpty }
//            .map{ MoneyUtil.formatDecimals(MoneyUtil.parseDecimal($0.1) ?? 0, decimals: $0.0) }
//            .asDriver(onErrorJustReturn: "")
//            .drive(amountField.rx.text)
//            .disposed(by: bag)
//    }
//
//    func setupFeeField() {
//        feeField.delegate = self
//        feeField.text = MoneyUtil.getScaledTextTrimZeros(kMinFee, decimals: 8)
//    }
//
//    func setupAttachementField() {
//        attachmentField.textColor = AppColors.darkGreyText
//        attachmentField.delegate = self
//        attachmentField.placeholderText = "Enter attachment here..."
//    }
//
//    lazy var totalMinusFeeDriver: Driver<Money> = {
//        Driver.combineLatest(self.selectedAsset, self.viewModel.fee) { (ab, fee) -> Money in
//            guard let fee = fee.toOpt else {return Money(0, 0)}
//
//            if (ab.assetId == "") {
//                return Money(ab.balance - fee.amount, ab.getDecimals())
//            } else {
//                return Money(ab.balance, ab.getDecimals())
//            }
//        }
//    }()
//
//    func setupTotalView() {
//        totalMinusFeeDriver
//            .map{ "Use total balance \($0.displayText) minus fee" }
//            .drive(useTotalButton.rx.title())
//            .disposed(by: bag)
//
//        useTotalButton.rx.tap.asObservable()
//            .withLatestFrom(totalMinusFeeDriver.asObservable().map{ $0.displayText })
//            .subscribe(onNext: { t in
//                self.amountField.text = t
//                self.amountField.sendActions(for: .editingChanged)
//            })
//            .disposed(by: bag)
//    }
//
//    func validationResult<A>(field: UITextField, errorLabel: UILabel, value: Driver<Try<A>>) {
//        value.map{ $0.error }
//            .drive(errorLabel.rx.text)
//            .disposed(by: bag)
//
//        let fieldDidEnd = field.rx.controlEvent(.editingDidEnd).asDriver().map { true }
//        Driver
//            .combineLatest(fieldDidEnd, value) { $0 && $1.exists}
//            .drive(errorLabel.rx.isHidden)
//            .disposed(by: bag)
//    }
//
//    private func setupValidations() {
//        viewModel.transferRequest.map { $0.exists }
//            .drive(submitButton.rx.isEnabled)
//            .disposed(by: bag)
//
//        validationResult(field: addressField, errorLabel: addressError, value: viewModel.address)
//        validationResult(field: amountField, errorLabel: amountErrorLabel, value: viewModel.amount)
//        validationResult(field: feeField, errorLabel: feeError, value: viewModel.fee)
//    }
//
//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let abVc = segue.destination as? AddressBookViewController {
//            abVc.selectedAddress.asObservable().skip(1).subscribe(onNext: { addr in
//                self.addressField.text = addr?.address
//                self.addressField.becomeFirstResponder()
//                self.addressField.setNeedsLayout()
//            }).disposed(by: bag)
//        } else if let successVc = segue.destination as? TransferSuccessViewController
//            , let tx = sender as? BasicTransaction {
//            successVc.tx = tx
//        }
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == amountField {
//            return MoneyUtil.shouldChangeAmount(textField, currentDecimals, range, string)
//        } else if textField == feeField {
//            return MoneyUtil.shouldChangeAmount(textField, 8, range, string)
//        } else {
//            return true
//        }
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        guard let t = textView.text as NSString? else { return true }
//        let newString = t.replacingCharacters(in: range, with: text)
//        return newString.utf8.count <= viewModel.kMaxAttachmentSize
//    }
//
//    @IBAction func onFeeOptions(_ sender: Any) {
//        let options = [(100000, MoneyUtil.getScaledTextTrimZeros(100000, decimals: 8) + " WAVES (Economic)"),
//                       (150000, MoneyUtil.getScaledTextTrimZeros(150000, decimals: 8) + " WAVES (Standard)"),
//                       (200000, MoneyUtil.getScaledTextTrimZeros(200000, decimals: 8) + " WAVES (Premium)")]
//
//        let vc = UIAlertController(title: "Choose transaction fee", message: "", preferredStyle: .actionSheet)
//        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        for (fee, label) in options {
//            vc.addAction(UIAlertAction(title: label, style: .default, handler: { [weak self] _ in
//                self?.feeField.text = MoneyUtil.getScaledTextTrimZeros(Int64(fee), decimals: 8)
//                self?.feeField.sendActions(for: .editingChanged)
//            }))
//        }
//
//        present(vc, animated: true, completion: nil)
//    }
//
//    var submitBag = DisposeBag()
//    func onSubmit() {
//        WalletManager.restorePrivateKey()
//            .flatMapLatest{ pk -> Observable<TransferRequest> in
//                self.viewModel.validTransferRequest.asObservable()
//                    .map{ req in req.senderPrivateKey = pk; return req }
//            }
//            .flatMapLatest{ req -> Observable<TransferTransaction> in
//                return NodeManager.broadcastTransfer(transferRequest: req)
//            }
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { tx in
//                self.performSegue(withIdentifier: "TransactionSuccess", sender: self.savePending(tx: tx))
//                self.submitBag = DisposeBag()
//            }, onError: { err in
//                self.submitBag = DisposeBag()
//                self.presentBasicAlertWithTitle(title: err.localizedDescription)
//            })
//            .disposed(by: submitBag)
//
//    }
//
//    func savePending(tx: TransferTransaction) -> BasicTransaction {
//        let realm = try! Realm()
//        tx.isPending = true
//        let bt = BasicTransaction(tx: tx)
//        try! realm.write {
//            realm.add(tx, update: true)
//            bt.addressBook = realm.create(AddressBook.self, value: ["address": bt.counterParty], update: true)
//            realm.add(bt, update: true)
//        }
//        return bt
//    }
//
//    func setupSubmit() {
//        submitButton.rx.tap.asObservable()
//            .throttle(0.5, scheduler: MainScheduler.instance)
//            .do(onNext: { self.submitButton.isEnabled = false })
//            .subscribe(onNext: { _ in
//                self.onSubmit()
//            })
//            .disposed(by: bag)
//    }
//
//    @objc func handleOpenUrl() {
//        if let p = OpenUrlManager.getOpenUrlParams() {
//            setValues(address: p.0, assetId: p.1, amount: p.2, attachment: p.3)
//        }
//        OpenUrlManager.openUrl = nil
//    }
//
//    func setValues(address: String, assetId: String?, amount: String?, attachment: String?) {
//        addressField.text = Address.isValidAddress(address: address) ? address : ""
//        addressField.sendActions(for: .editingChanged)
//        let ab = selectAccountController.selectAccount(assetId: assetId ?? "")
//        DispatchQueue.main.async {
//            if let amount = amount, let ab = ab, let a = Int64(amount) {
//                 self.amountField.text = MoneyUtil.getScaledTextTrimZeros(a, decimals: ab.getDecimals())
//            } else {
//                self.amountField.text = ""
//            }
//            self.amountField.sendActions(for: .editingDidEnd)
//        }
//
//        attachmentField.text = attachment
//        setupFeeField()
//        feeField.sendActions(for: .editingChanged)
//        self.view.endEditing(true)
//
//    }
//
//    @IBAction func unwindFromSuccessClear(unwindSegue: UIStoryboardSegue) {
//        setValues(address: "", assetId: nil, amount: nil, attachment: nil)
//        DispatchQueue.main.async {
//            self.tabBarController?.selectedIndex = 1
//        }
//    }
//
//    @IBAction func unwindFromSuccessRepeat(unwindSegue: UIStoryboardSegue) {
//        amountField.sendActions(for: .editingChanged)
//    }
//
//    lazy var readerVC: QRCodeReaderViewController = {
//        let builder = QRCodeReaderViewControllerBuilder {
//            $0.reader = QRCodeReader()
//        }
//
//        return QRCodeReaderViewController(builder: builder)
//    }()
//
//    @IBAction func onScanQR(_ sender: Any) {
//        // Or by using the closure pattern
//        guard QRCodeReader.isAvailable() else { return }
//        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
//            if let s = result?.value
//                , Address.isValidAddress(address: s) {
//                 self.setValues(address: s, assetId: nil, amount: nil, attachment: nil)
//            } else if let s = result?.value
//                , let p = OpenUrlManager.parseUrlParams(openUrl: URL(string: s)) {
//                self.setValues(address: p.0, assetId: p.1, amount: p.2, attachment: p.3)
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
//
//        // Presents the readerVC as modal form sheet
//        readerVC.modalPresentationStyle = .formSheet
//        present(readerVC, animated: true, completion: nil)
//    }
//}
//
//extension SendViewController: QRCodeReaderViewControllerDelegate {
//
//    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
//        reader.stopScanning()
//
//        if !result.value.isEmpty
//            , let p = OpenUrlManager.parseUrlParams(openUrl: URL(string: result.value)) {
//            setValues(address: p.0, assetId: p.1, amount: p.2, attachment: p.3)
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//
//    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
//    }
//
//    func readerDidCancel(_ reader: QRCodeReaderViewController) {
//        reader.stopScanning()
//
//        dismiss(animated: true, completion: nil)
//    }
//
//}
