//
//  SendTransactionScriptErrorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/21/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionScriptErrorView: PopupActionView, NibLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        setupLocalization()
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        dismiss()
    }
    
    private func setupLocalization() {
        
        labelTitle.text = Localizable.Waves.Transactionscript.Label.title
        labelSubtitle.text = Localizable.Waves.Transactionscript.Label.subtitle
        buttonOkey.setTitle(Localizable.Waves.Transactionscript.Button.okey, for: .normal)
    }
    
    func update() {
        frame = UIScreen.main.bounds
        layoutIfNeeded()
    }
}


extension TransactionScriptErrorView {
    
    class func show() {
        
        let view = TransactionScriptErrorView.loadFromNib()
        view.update()
        AppDelegate.shared().window?.addSubview(view)
        view.setupInitialAnimationPoition()
    }
}
