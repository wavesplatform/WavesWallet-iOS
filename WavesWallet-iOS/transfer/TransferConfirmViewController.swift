//
//  TransferConfirmViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 22/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TransferConfirmViewController: UITableViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var assetLabel: UILabel!
    
    var transferRequest: Driver<Try<TransferRequest>>!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInfo()
        /*confirmButton.rx.tap.asObservable().withLatestFrom(transferRequest.asObservable())
            .filter{ $0.exists }
            .map{ return $0.toOpt! }
            .flatMapLatest { request -> Observable<TransferTransaction> in
                //request.senderPrivateKey = WalletManager.getPrivateKeyAccount()
                print(request.toJSON()?.description ?? "Unknown request")
                return NodeManager.broadcastTransfer(transferRequest: request)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { tx in
                print(tx)
                self.performSegue(withIdentifier: "TransactionSuccess", sender: nil)
            }, onError: { err in
                self.showErrorAler(err: err)
            })
            .addDisposableTo(bag)*/
    }
    
    func setupInfo() {
        
    }
    
    func showErrorAler(err: Error) {
        let message = "Failed to send transaction. Reason: \(err.localizedDescription)"
        let alertView = UIAlertController(title: "Transfer Error",
                                          message: message as String, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        
    }

}
