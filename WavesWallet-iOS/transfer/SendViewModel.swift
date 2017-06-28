//
//  SendViewModel.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 19/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SendViewModel {
    let addressText: Observable<String>
    let amountText: Observable<String>
    let feeText: Observable<String>
    let attachmentText: Observable<String>
    
    let selectedAsset: Observable<AssetBalance>
    let wavesBalance: Observable<AssetBalance>
    
    let kMinFee: Int64 = 100000
    let kMaxAttachmentSize = 140
    
    lazy var address: Driver<Try<String>> = {
        return self.addressText
            .map { a in
                return Address.isValidAddress(address: a) ?
                    Try.Val(a)
                    : Try.Err("Invalid address")
            }
            .asDriver(onErrorJustReturn: Try.Err("Invalid address"))
    }()
    
    lazy var amountValue: Observable<Money?> = {
        return Observable.combineLatest(self.amountText, self.selectedAsset) {
            MoneyUtil.parseMoney($0, $1.getDecimals()) }
    }()
    
    func validateAmount(_ amount: Money?, _ balance: Int64) -> String? {
        let invalidAmount = "Invalid amount"
        
        if let amount = amount {
            if amount.amount <= 0 { return invalidAmount }
            else if balance < amount.amount { return "Insufficient balance" }
            else { return nil }
        } else {
            return invalidAmount
        }
    }
    
    lazy var amount: Driver<Try<Money>> = {
        return Observable.combineLatest(self.amountValue, self.selectedAsset) {
            if let err = self.validateAmount($0, $1.balance) {
                return Try.Err(err)
            } else {
                return Try.Val($0!)
            }
        }.asDriver(onErrorJustReturn: Try.Err("Invalid amount"))
    }()
    
    lazy var feeValue: Observable<Money?> = {
        return Observable.combineLatest(self.feeText, self.wavesBalance) {
            MoneyUtil.parseMoney($0, $1.getDecimals())
        }
    }()
    
    func validateFee(_ fee: Money?, _ wavesBalance: Int64) -> String? {
        if let err = validateAmount(fee, wavesBalance) { return err }
        else if fee?.amount ?? 0 < kMinFee { return "Fee is too low" }
        else { return nil }
    }
    
    lazy var fee: Driver<Try<Money>> = {
        return Observable.combineLatest(self.feeValue, self.wavesBalance) {
            if let err = self.validateFee($0, $1.balance) {
                return Try.Err(err)
            } else {
                return Try.Val($0!)
            }
            }.asDriver(onErrorJustReturn: Try.Err("Invalid amount"))
    }()

    lazy var attachment: Driver<Try<String>> = {
        return self.attachmentText
            .map{ $0.utf8.count <= self.kMaxAttachmentSize ? Try.Val($0) : Try.Err("Attachment is too long") }
            .asDriver(onErrorJustReturn: Try.Err("Invalid attachment"))
    }()
    
    lazy var walletPublicKey: Driver<PublicKeyAccount> = {
        return WalletManager.getWalletPublicKey()
            .asDriver(onErrorJustReturn: PublicKeyAccount(publicKey: []))
    }()
    
    lazy var transferRequest: Driver<Try<TransferRequest>> = {
        return Driver.combineLatest(self.selectedAsset.asDriver(onErrorJustReturn: AssetBalance()), self.walletPublicKey, self.address, self.amount, self.fee, self.attachment) {
            (selectedAsset, senderPubKey, recipient, amount, fee, attachment) -> Try<TransferRequest> in
            if let recipient = recipient.toOpt
                , let amount = amount.toOpt
                , let fee = fee.toOpt
                , let attachment = attachment.toOpt {
                return Try.Val(TransferRequest(assetId: selectedAsset.assetId, senderPublicKey: senderPubKey, recipient: recipient, amount: amount, fee: fee, attachment: attachment))
            } else {
                return Try.Err("Invalid transfer")
            }
        }
    }()

    lazy var validTransferRequest: Driver<TransferRequest> = {
        return self.transferRequest.filter{ $0.exists }.map {$0.toOpt!}
    }()

    
    init(input: (
            addressText: Observable<String>,
            amountText: Observable<String>,
            feeText: Observable<String>,
            attachmentText: Observable<String>
        ),
         dependency: (
            selectedAsset: Observable<AssetBalance>,
            wavesBalance: Observable<AssetBalance>
        )) {
        self.addressText = input.addressText
        self.amountText = input.amountText
        self.feeText = input.feeText
        
        self.selectedAsset = dependency.selectedAsset
        self.wavesBalance = dependency.wavesBalance
        self.attachmentText = input.attachmentText
    }
    

}
