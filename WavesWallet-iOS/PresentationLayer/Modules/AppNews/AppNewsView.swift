//
//  AppNewsView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 2/15/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class AppNewsView: PopupActionView, NibLoadable {

    struct Model {
        let title: String
        let subtitle: String
        let image: UIImage
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonOkey.setTitle(Localizable.Waves.Appnews.Button.okey, for: .normal)
        
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        dismiss()
    }
}

extension AppNewsView: ViewConfiguration {
    
    func update(with model: Model) {
        
        labelTitle.text = model.title
        labelSubtitle.text = model.subtitle
        imageView.image = model.image
        
        frame = UIScreen.main.bounds
        layoutIfNeeded()
    }
}

extension AppNewsView {
    
    class func show(model: Model) {
        let view = AppNewsView.loadFromNib()
        view.update(with: model)
        AppDelegate.shared().window?.addSubview(view)
        view.setupInitialAnimationPoition()
    }
}
