//
//  TransferViewModel.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 18/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import Gloss

class TransferRequest {
    let assetId: String
    let senderPublicKey: PublicKeyAccount
    let recipient: String
    let amount: Money
    let fee: Money
    let attachment: String
    
    let transactionType: UInt8 = 4
    let timestamp: Int64
    
    var senderPrivateKey: PrivateKeyAccount? {
        didSet {
            //self.timestamp = 1492954155766//Int64(Date().millisecondsSince1970)
        }
    }
    
    init(assetId: String, senderPublicKey: PublicKeyAccount, recipient: String, amount: Money, fee: Money, attachment: String) {
        self.assetId = assetId
        self.senderPublicKey = senderPublicKey
        self.recipient = recipient
        self.amount = amount
        self.fee = fee
        self.timestamp = Int64(Date().millisecondsSince1970)
        self.attachment = attachment
    }
    
    
    var toSign: [UInt8] {
        let assetIdBytes = assetId.isEmpty ? [UInt8(0)] :  ([UInt8(1)] + Base58.decode(assetId))
        let feeAssetIdBytes = [UInt8(0)]
        let s1 = [transactionType] + senderPublicKey.publicKey
        let s2 = assetIdBytes + feeAssetIdBytes + toByteArray(timestamp) + toByteArray(amount.amount) + toByteArray(fee.amount)
        let s3 = Base58.decode(recipient) + attachment.arrayWithSize()
        return s1 + s2 + s3
        /*let assetIdBytes = assetId.isEmpty ? [UInt8(0)] :  ([UInt8(1)] + Base58.decode(assetId))
        let feeAssetIdBytes = [UInt8(0)]
        return //[UInt8(transactionType)]
            senderPublicKey.publicKey
            + assetIdBytes
            + feeAssetIdBytes
            + toByteArray(timestamp)
            + toByteArray(amount.amount)
            + toByteArray(fee.amount)
            + Base58.decode(recipient)
            + arrayWithSize(attachment)
 */
    }
    
    var id: [UInt8] {
        return Hash.fastHash(toSign)
    }
    
    func getSignature() -> [UInt8] {
        guard let pk = senderPrivateKey else { return [] }
        let b = toSign
        print("ToSign")
        print(Base58.encode(b))
        return Hash.sign(b, pk.privateKey)
    }
    
    func toJSON() -> JSON? {
        let asset: String? = assetId.isEmpty ? nil : assetId
        let feeAsset: String? = nil
        
        return jsonify([
            "type" ~~> transactionType,
            "id" ~~> Base58.encode(id),
            "sender" ~~> senderPublicKey.address,
            "senderPublicKey" ~~> Base58.encode(senderPublicKey.publicKey),
            "fee" ~~> fee.amount,
            "timestamp" ~~> timestamp,
            "signature" ~~> Base58.encode(getSignature()),
            "recipient" ~~> recipient,
            "assetId" ~~> asset,
            "amount" ~~> amount.amount,
            "feeAsset" ~~> feeAsset,
            "attachment" ~~> Base58.encode(Array(attachment.utf8))
            ])
    }

}
