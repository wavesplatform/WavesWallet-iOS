//
//  SmartTransactionKind+UIImage.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 07/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

extension DomainLayer.DTO.SmartTransaction.Kind {

    var image: UIImage {
        switch self {
        case .receive(let tx):
            if tx.hasSponsorship {
                return Images.tSponsoredPlus48.image
            } else {
                return Images.assetReceive.image
            }

        case .sent:
            return Images.tSend48.image

        case .startedLeasing:
            return Images.walletStartLease.image

        case .exchange:
            return Images.tExchange48.image

        case .canceledLeasing:
            return Images.tCloselease48.image

        case .tokenGeneration:
            return Images.tTokengen48.image

        case .tokenBurn:
            return Images.tTokenburn48.image

        case .tokenReissue:
            return Images.tTokenreis48.image

        case .selfTransfer:
            return Images.tSelftrans48.image

        case .createdAlias:
            return Images.tAlias48.image

        case .incomingLeasing:
            return Images.tIncominglease48.image

        case .unrecognisedTransaction:
            return Images.tUndefined48.image

        case .massSent:
            return Images.tMasstransfer48.image

        case .massReceived:
            return Images.tMassreceived48.image

        case .spamReceive:
            return Images.tSpamReceive48.image

        case .spamMassReceived:
            return Images.tSpamMassreceived48.image

        case .data:
            return Images.tData48.image

        case .script(let isHasScript):
            if isHasScript {
                return Images.tSetscript48.image
            } else {
                return Images.tSetscriptCancel48.image
            }

        case .assetScript:
            return Images.tSetassetscript48.image

        case .sponsorship(let isEnabled, _):
            if isEnabled {
                return Images.tSponsoredEnable48.image
            } else {
                return Images.tSponsoredDisable48.image
            }
            
        case .invokeScript:
            return Images.tInvocationscript48.image
        }
    }
}
