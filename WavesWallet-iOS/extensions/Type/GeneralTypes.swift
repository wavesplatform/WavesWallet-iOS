//
//  GeneralTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 06/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum GeneralTypes {}

extension GeneralTypes {
    enum ViewModel {}
    enum DTO {}
}

extension GeneralTypes.DTO {

    struct Transaction {

        struct Asset {
            let isSpam: Bool
            let isGeneral: Bool                        
            let balance: Balance
        }

        struct Receive {
            let asset: Asset
        }

        struct Sent {
            let asset: Asset
        }

        struct StartedLeasing {
            let asset: Asset
        }

        struct Exchange {
            struct Order {
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
        }

        struct TokenReissue {
            let asset: Asset
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
            case receive(Receive)
            case sent(Sent)
            case startedLeasing(StartedLeasing)
            case exchange(Exchange)
            case canceledLeasing(CanceledLeasing)
            case tokenGeneration(TokenGeneration)
            case tokenBurn(TokenBurn)
            case tokenReissue(TokenReissue)
            case selfTransfer(SelfTransfer)
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
