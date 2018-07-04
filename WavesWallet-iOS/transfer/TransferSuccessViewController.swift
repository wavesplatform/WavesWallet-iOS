//
//  TransferSuccessViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 18/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm

class TransferSuccessViewController: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    
    var transferRequest: Driver<Try<TransferRequest>>!
    var tx: BasicTransaction!
    
    var favoriteState: FavoriteViewState = .notFavourited {
        didSet {
            if favoriteState == .notFavourited {
                favoriteButton.setImage(#imageLiteral(resourceName: "not_star_btn"), for: .normal)
                favoriteLabel.text = "To address book"
                addressNameLabel.isHidden = true
            } else {
                favoriteButton.setImage(#imageLiteral(resourceName: "star_btn"), for: .normal)
                favoriteLabel.text = "In address book"
                addressNameLabel.isHidden = false
                addressNameLabel.text = tx.addressBook?.name
            }
        }
    }
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBlurBackground()
        
        amountLabel.text = "\u{2011}" + MoneyUtil.getScaledTextTrimZeros(tx.amount, decimals: Int(tx.asset?.decimals ?? 0))
        addressLabel.text = tx.counterParty
        assetNameLabel.text = tx.asset?.name ?? "Unknown"
        
        if let addr = tx.addressBook {
            Observable.from(object: addr)
                .map { $0.name != nil ? .favourited : .notFavourited }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { self.favoriteState = $0 })
                .disposed(by: bag)
        }
    }
    
    func addBlurBackground() {
        self.view.backgroundColor = .clear//AppColors.wavesColor.withAlphaComponent(0.9)
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blur.tintColor = AppColors.wavesColor
        blur.frame = self.view.frame
        self.view.insertSubview(blur, at: 0)
        let bg = UIView(frame: self.view.frame)
        bg.backgroundColor = AppColors.wavesColor.withAlphaComponent(0.5)
        self.view.insertSubview(bg, at: 1)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRepeat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        if favoriteState == .notFavourited {
            AddressBookManager.askForSaveAddress(parentController: self, address: tx.counterParty)
        } else {
            AddressBookManager.askForDeletion(parentController: self, address: tx.counterParty)
        }
    }
    
}
