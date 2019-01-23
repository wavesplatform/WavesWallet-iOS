//
//  SendTransactionScriptErrorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/21/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let defaultBottomOffset: CGFloat = 24
    
    enum Shadow {
        static let offset = CGSize(width: 0, height: 4)
        static let opacity: Float = 0.2
        static let shadowRadius: Float = 4
    }
}

final class TransactionScriptErrorView: UIView, NibLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewBackground: UIView!
    @IBOutlet private weak var bottomOffset: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        setupLocalization()
        viewContainer.setupShadow(options: .init(offset: Constants.Shadow.offset,
                                                 color: .black,
                                                 opacity: Constants.Shadow.opacity,
                                                 shadowRadius: Constants.Shadow.shadowRadius,
                                                 shouldRasterize: true))
        
        viewBackground.alpha = 0
        bottomOffset.constant = initialViewPosition

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.bottomOffset.constant = Constants.defaultBottomOffset
            UIView.animate(withDuration: Constants.animationDuration) {
                self.viewBackground.alpha = 1
                self.layoutIfNeeded()
            }
        }
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        bottomOffset.constant = initialViewPosition

        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.layoutIfNeeded()
            self.viewBackground.alpha = 0
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
    
    private var initialViewPosition: CGFloat {
        return -(viewContainer.frame.size.height + Constants.defaultBottomOffset)
    }
    
    private func setupLocalization() {
        
        labelTitle.text = Localizable.Waves.Transactionscript.Label.title
        labelSubtitle.text = Localizable.Waves.Transactionscript.Label.subtitle
        buttonOkey.setTitle(Localizable.Waves.Transactionscript.Button.okey, for: .normal)
    }
}

extension TransactionScriptErrorView {
    
    class func show() {
        
        let view = TransactionScriptErrorView.loadFromNib()        
        view.frame = UIScreen.main.bounds
        AppDelegate.shared().window?.addSubview(view)
    }
}
