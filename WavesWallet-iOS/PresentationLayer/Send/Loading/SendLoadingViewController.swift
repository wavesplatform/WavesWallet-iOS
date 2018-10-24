//
//  SendLoadingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol SendResultDelegate: AnyObject {

    func sendResultDidFail(_ error: String)
}

final class SendLoadingViewController: UIViewController {

    @IBOutlet private weak var labelSending: UILabel!
    
    weak var delegate: SendResultDelegate?
    var input: SendConfirmationViewController.Input!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelSending.text = Localizable.SendLoading.Label.sending
//        send()
    }
    
    private func send() {
    
        let interactor: SendInteractorProtocol = SendInteractor()
        interactor.send(fee: input.fee, recipient: input.recipient, assetId: input.assetId, amount: input.amount, attachment: input.attachment, isAlias: input.isAlias)
            .subscribe(onNext: { [weak self] success in
                
            }).dispose()
    }
}
