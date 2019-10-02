//
//  MigrateAccountsHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/25/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 40
}

final class MigrateAccountsHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var bgContent: UIView!
    
}

extension MigrateAccountsHeaderView: ViewConfiguration {
    
    func update(with model: String) {
        labelTitle.text = model
    }
}

extension MigrateAccountsHeaderView: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
