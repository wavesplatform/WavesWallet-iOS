//
//  DexAssetScriptMessageViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/5/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let buttonDeltaWidth: CGFloat = 70
    static let spaceAssets: CGFloat = 24
    static let icon: CGSize = CGSize(width: 48, height: 48)
    static let sponsoredIcon = CGSize(width: 18, height: 18)
}

final class DexScriptAssetMessageViewController: UIViewController {

    @IBOutlet private weak var imageViewIcon1: UIImageView!
    @IBOutlet private weak var imageViewIcon2: UIImageView!
    @IBOutlet private weak var assetsSpace: NSLayoutConstraint!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonContinue: HighlightedButton!
    @IBOutlet private weak var buttonCancel: HighlightedButton!
    @IBOutlet private weak var buttonDoNotShow: UIButton!
    @IBOutlet private weak var buttonDoNotShowWidthContraint: NSLayoutConstraint!
    @IBOutlet private weak var iconCheckmark: UIImageView!
    
    private var doNotShowAgain = false
    private let disposeBag = DisposeBag()
    
    weak var output: DexScriptAssetMessageModuleOutput?
    var input: DexScriptAssetMessageModuleBuilder.Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        setupUI()
    }

    @IBAction private func doNotShowAgain(_ sender: Any) {
        doNotShowAgain = !doNotShowAgain
        iconCheckmark.image = doNotShowAgain ? Images.Checkbox.checkboxOn.image : Images.Checkbox.checkboxOff.image

        output?.dexScriptAssetMessageModuleOutputDidTapCheckmark(amountAsset: input.amountAsset,
                                                                 priceAsset: input.priceAsset,
                                                                 doNotShow: doNotShowAgain)
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
        dismiss()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        input.continueAction?()
        dismiss()
    }
    
    private func dismiss() {
        if let popup = parent as? PopupViewController {
            popup.dismissPopup()
        }
    }
}

private extension DexScriptAssetMessageViewController {
    func setupLocalization() {
        labelTitle.text = Localizable.Waves.Dexscriptassetmessage.Label.title
        labelSubtitle.text = Localizable.Waves.Dexscriptassetmessage.Label.description
        buttonContinue.setTitle(Localizable.Waves.Dexscriptassetmessage.Button.continue, for: .normal)
        buttonCancel.setTitle(Localizable.Waves.Dexscriptassetmessage.Button.cancel, for: .normal)
        let doNotShowAgainTitle = Localizable.Waves.Dexscriptassetmessage.Button.doNotShowAgain
        buttonDoNotShow.setTitle(doNotShowAgainTitle, for: .normal)
        
        guard let font = buttonDoNotShow.titleLabel?.font else { return }
        buttonDoNotShowWidthContraint.constant = doNotShowAgainTitle.maxWidth(font: font) + Constants.buttonDeltaWidth
    }
    
    func setupUI() {
        
        if input.assets.count == 1 {
            assetsSpace.constant -= Constants.spaceAssets + imageViewIcon1.frame.size.width
       
            guard let asset = input.assets.first else { return }
            setup(imageViewIcon: imageViewIcon1, asset: asset)
        }
        else {
            guard let asset1 = input.assets.first,
                let asset2 = input.assets.last else { return }
            
            setup(imageViewIcon: imageViewIcon1, asset: asset1)
            setup(imageViewIcon: imageViewIcon2, asset: asset2)
        }
    }
    
    func setup(imageViewIcon: UIImageView, asset: DomainLayer.DTO.Asset) {
        let sponsoredSize = asset.isSponsored ? Constants.sponsoredIcon : nil
        
        AssetLogo.logo(icon: asset.iconLogo,
                       style: AssetLogo.Style(size: Constants.icon,
                                              sponsoredSize: sponsoredSize,
                                              font: UIFont.systemFont(ofSize: 15),
                                              border: nil))
            .observeOn(MainScheduler.instance)
            .bind(to: imageViewIcon.rx.image)
            .disposed(by: disposeBag)
    }
}
