//
//  TransactionCardActionsCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let duration: TimeInterval = 2
}

final class TransactionCardActionsCell: UITableViewCell, Reusable {

    struct Model {
        enum Button {
            case viewOnExplorer
            case copyTxID
            case copyAllData
            case sendAgain
            case cancelLeasing
        }

        let buttons: [Button]
    }

    @IBOutlet private var actionsControl: ActionsControl!

    var tapOnButton: ((Model.Button) -> Void)?
}

// TODO: ViewConfiguration

extension TransactionCardActionsCell: ViewConfiguration {

    func update(with model: TransactionCardActionsCell.Model) {


        let buttons = model.buttons.map { [weak self] (button) -> ActionsControl.Model.Button in

            return button.createAction({ [weak self] (button) in
                self?.tapOnButton?(button)
            })
        }

        actionsControl.update(with: ActionsControl.Model.init(buttons: buttons))
    }
}

private extension TransactionCardActionsCell.Model.Button {

    func createAction(_ handler: @escaping (TransactionCardActionsCell.Model.Button) -> Void) -> ActionsControl.Model.Button {
        switch self {
        case .viewOnExplorer:
            return viewOnExplorer {
                handler(self)
            }
        case .copyTxID:
            return copyTxId {
                handler(self)
            }

        case .copyAllData:
            return copyAllData {
                handler(self)
            }

        case .sendAgain:
            return sendAgainButton {
                handler(self)
            }

        case .cancelLeasing:
            return cancelLeasingButton {
                handler(self)
            }
        }
    }

//TODO: Localization

    func cancelLeasingButton(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .error400,
                     textColor: .white,
                     text: Localizable.Waves.Transactioncard.Title.cancelLeasing,
                     icon: Images.tCloselease18.image,
                     effectsOnTap: []) {
                        action()
        }
    }

    func sendAgainButton(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .warning600,
                    textColor: .white,
                    text: Localizable.Waves.Transactioncard.Title.sendAgain,
                    icon: Images.tResend18.image,
                    effectsOnTap: []) {
            action()
        }
    }

    func viewOnExplorer(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .basic50,
                    textColor: .black,
                    text: Localizable.Waves.Transactioncard.Title.viewOnExplorer,
                    icon: Images.viewexplorer18Black.image,
                    effectsOnTap: [.impactOccurred]) {
            action()
        }
    }

    func copyTxId(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .basic50,
                    textColor: .black,
                    text: Localizable.Waves.Transactioncard.Title.copyTXID,
                    icon: Images.copy18Black.image,
                    effectsOnTap: [.changeIconForTime(Images.checkSuccess.image, Constants.duration),
                                   .changeTitleForTime(Localizable.Waves.Transactioncard.Title.copied, Constants.duration),
                                   .changeTitleColorForTime(.success400, Constants.duration),
                                   .impactOccurred]) {
            action()
        }
    }

    func copyAllData(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .basic50,
                     textColor: .black,
                     text: Localizable.Waves.Transactioncard.Title.copyAllData,
                     icon: Images.copy18Black.image,
                     effectsOnTap: [.changeIconForTime(Images.checkSuccess.image, Constants.duration),
                                    .changeTitleForTime(Localizable.Waves.Transactioncard.Title.copied, Constants.duration),
                                    .changeTitleColorForTime(.success400, Constants.duration),
                                    .impactOccurred]) {
                        action()
        }
    }

}


