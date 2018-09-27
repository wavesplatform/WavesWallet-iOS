//
//  StartLeasingGeneratorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class StartLeasingGeneratorView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    @IBOutlet private weak var viewContentTextField: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = Localizable.StartLeasing.Label.generator
        textField.placeholder = Localizable.StartLeasing.Label.nodeAddress
        viewContentTextField.addTableCellShadowStyle()
        inputScrollView.inputDelegate = self
        inputScrollView.startOffset = 0
        inputScrollView.update(with: ["kjj", "kjllll", "jkjhgfh"])
    }
}

extension StartLeasingGeneratorView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        
    }
    
}

private extension StartLeasingGeneratorView {
    
    @IBAction func deleteTapped(_ sender: Any) {
        
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        
    }
}
