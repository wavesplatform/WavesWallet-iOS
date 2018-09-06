//
//  TransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
extension DomainLayer.DTO {

    struct Recipient {
        struct Contact {
            let name: String
        }

        let sender: String
        let contant: Contact?
    }

    struct Transaction {

        typealias Asset = DomainLayer.DTO.Asset
        typealias Recipient = DomainLayer.DTO.Recipient

        struct Receive {
            let asset: Asset
        }

        struct Transfer {
            let balance: Balance
            let asset: Asset
            let recipient: Recipient
        }

        struct StartedLeasing {
            let asset: Asset
        }

        struct Exchange {
            struct Order {
                enum Kind {
                    case buy
                    case sell
                }
                let asset: Asset
            }
        }

        struct CanceledLeasing {
            let asset: Asset
        }

        struct TokenGeneration {
            let asset: Asset            
        }

        struct TokenBurn {
            let asset: Asset
            let balance: Balance
        }

        struct TokenReissue {
            let asset: Asset
            let balance: Balance
        }

        struct SelfTransfer {
            let asset: Asset
        }

        struct CreatedAlias {
            let asset: Asset
        }

        struct IncomingLeasing {
            let asset: Asset
        }

        struct MassSent {
            let asset: Asset
        }

        struct MassReceived {
            let asset: Asset
        }

        struct SpamReceive {
            let asset: Asset
        }

        struct SpamMassReceived {
            let asset: Asset
        }

        struct Data {
        }

        enum Kind {
            case receive(Transfer)
            case sent(Transfer)
            case selfTransfer(Transfer)

            case startedLeasing(StartedLeasing)
            case exchange(Exchange)
            case canceledLeasing(CanceledLeasing)
            case tokenGeneration(TokenGeneration)
            case tokenBurn(TokenBurn)
            case tokenReissue(TokenReissue)

            case createdAlias(CreatedAlias)
            case incomingLeasing(IncomingLeasing)
            case unrecognisedTransaction
            case massSent(MassSent)
            case massReceived(MassReceived)
            case spamReceive(SpamReceive)
            case spamMassReceived(SpamMassReceived)
            case data(Data)
        }

        let id: String
        let kind: Kind
        let date: Date
    }
}
