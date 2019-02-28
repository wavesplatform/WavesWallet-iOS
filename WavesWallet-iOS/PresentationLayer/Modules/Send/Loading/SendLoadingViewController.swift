//
//  SendLoadingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

final class SendLoadingViewController: UIViewController {

    @IBOutlet private weak var labelSending: UILabel!
    
    weak var delegate: SendResultDelegate?
    var input: SendConfirmationViewController.Input!
    
    let interactor: SendInteractorProtocol = SendInteractor()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        labelSending.text = Localizable.Waves.Sendloading.Label.sending
        navigationItem.hidesBackButton = true
        send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func showComplete() {
        let vc = StoryboardScene.Send.sendCompleteViewController.instantiate()
        vc.input = .init(assetName: input.asset.displayName,
                         amount: input.amount,
                         address: input.displayAddress,
                         amountWithoutFee: input.amountWithoutFee)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func send() {
      
        let assetId = input.asset.isWaves ? "" : input.asset.id
        interactor.send(fee: input.fee, recipient: input.address, assetId: assetId, amount: input.amount, attachment: input.attachment, feeAssetID: input.feeAssetID)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] status in
                
                switch status {
                case .success:
                    self?.showComplete()
                
                case .error(let error):
                    self?.delegate?.sendResultDidFail(error)
                }
                
        }).disposed(by: disposeBag)
    }
}
