//
//  DexCreateInputView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexCreateOrderInputView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    var input: DexCreateOrder.DTO.Input!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}


extension DexCreateOrderInputView {
    
}
