//
//  AssetsSearchAssetCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer
import RxSwift
import Extensions

final class AssetsSearchAssetCell: UITableViewCell, Reusable {
    
    struct Model {
        
        enum State {
            case lock
            case selected
            case unselected
        }
        
        let asset: DomainLayer.DTO.Asset
        let state: State
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var assetIconImageView: UIImageView!
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetIconImageView.image = nil
        disposeBag = DisposeBag()
    }
}

extension AssetsSearchAssetCell: ViewConfiguration {
    
    func update(with model: AssetsSearchAssetCell.Model) {
        
        titleLabel.text = model.asset.ticker ?? model.asset.displayName
        
        switch model.state {
        case .lock:
            iconImageView.image = Images.draglock22Disabled400.image
            
        case .selected:
            iconImageView.image = Images.on.image
            
        case .unselected:
            iconImageView.image = Images.off.image
        }
        
        AssetLogo.logo(icon: model.asset.iconLogo,
                       style: .medium)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                guard let self = self else { return }
                self.assetIconImageView.image = image
            })
            .disposed(by: disposeBag)
    }
}
