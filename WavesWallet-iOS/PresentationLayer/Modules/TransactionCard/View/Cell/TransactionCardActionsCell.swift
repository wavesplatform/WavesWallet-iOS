//
//  TransactionCardActionsCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardActionsCell: UITableViewCell, Reusable {

    struct Model {
        enum Button {
            case viewOnExplorer
            case copyTxID
            case copyAllData
            case sendAgain
//            case cancelLeasing
        }

        let buttons: [Button]
    }

    @IBOutlet private var actionsControl: ActionsControl!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// TODO: ViewConfiguration

extension TransactionCardActionsCell: ViewConfiguration {

    func update(with model: TransactionCardActionsCell.Model) {


        let buttons = model.buttons.map { (button) -> ActionsControl.Model.Button in

            return button.createAction({ (button) in
                //TODO: Delegate
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
            return copyTxId {
                handler(self)
            }

        case .sendAgain:
            return sendAgainButton {
                handler(self)
            }
        }
    }

//TODO: Localization
    func sendAgainButton(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .warning600,
                    textColor: .white,
                    text: "Send again",
                    icon: Images.tResend18.image) {
            action()
        }
    }

    func cancelLeasingButton(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .error400,
                     textColor: .white,
                     text: "Cancel leasing",
                     icon: Images.tCloselease18.image) {
                        action()
        }
    }

    func viewOnExplorer(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .basic50,
                    textColor: .black,
                    text: "View on Explorer",
                    icon: Images.viewexplorer18Black.image) {
            action()
        }
    }

    func copyTxId(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .basic50,
                    textColor: .black,
                    text: "Copy TX ID",
                    icon: Images.copy18Black.image) {
            action()
        }
    }

    func copyAllData(_ action: @escaping () -> Void) -> ActionsControl.Model.Button {
        return .init(backgroundColor: .basic50,
                     textColor: .black,
                     text: "Copy all data",
                     icon: Images.copy18Black.image) {
                        action()
        }
    }

}


