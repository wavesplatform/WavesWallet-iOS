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

    struct Model {}

    @IBOutlet private var actionsControl: ActionsControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        update(with: .init())
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// TODO: ViewConfiguration

extension TransactionCardActionsCell: ViewConfiguration {

    func update(with model: TransactionCardActionsCell.Model) {

        let sendAgainButton = self.sendAgainButton() {

        }

        let cancelLeasingButton = self.cancelLeasingButton() {

        }

        let viewOnExplorer = self.viewOnExplorer() {

        }

        let copyTxId = self.copyTxId() {

        }

        let copyAllData = self.copyAllData() {

        }

        actionsControl.update(with: ActionsControl.Model.init(buttons: [sendAgainButton,
                                                                        cancelLeasingButton,
                                                                        viewOnExplorer,
                                                                        copyTxId,
                                                                        copyAllData]))
    }
}

private extension TransactionCardActionsCell {

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


