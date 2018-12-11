//
//  TokenBurnLoadingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

protocol TokenBurnLoadingViewControllerDelegate: AnyObject {
    
    func tokenBurnLoadingViewControllerDidFail(error: NetworkError)
}

final class TokenBurnLoadingViewController: UIViewController {

    @IBOutlet private weak var labelLoading: UILabel!
    
    var input: TokenBurnConfirmationViewController.Input!
    weak var delegate: TokenBurnLoadingViewControllerDelegate?
    
    private let interactor: TokenBurnSendInteractorProtocol = TokenBurnSendInteractorMock()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelLoading.text = Localizable.Waves.Tokenburn.Label.loading
        navigationItem.hidesBackButton = true
        
        interactor
            .burnAsset(asset: input.asset, fee: input.fee, quiantity: input.amount)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (status) in
                
                switch status {
                case .success:
                    self?.showCompleteScreen()
                    
                case .error(let error):
                    self?.delegate?.tokenBurnLoadingViewControllerDidFail(error: error)
                    self?.navigationController?.popViewController(animated: true)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    private func showCompleteScreen() {
        
        let isFullBurned = input.amount.amount == input.asset.avaliableBalance

        let vc = StoryboardScene.Asset.tokenBurnCompleteViewController.instantiate()
        vc.input = .init(assetName: input.asset.asset.displayName,
                         isFullBurned: isFullBurned,
                         delegate: input.delegate,
                         amount: input.amount)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
