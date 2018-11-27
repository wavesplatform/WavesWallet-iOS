//
//  StartLeasingLoadingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift


final class StartLeasingLoadingViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    
    var input: StartLeasingTypes.Input!
    
    private let startLeasingInteractor: StartLeasingInteractorProtocol = StartLeasingInteractor()
    private let transactions = FactoryInteractors.instance.transactions
    private let authorization = FactoryInteractors.instance.authorization
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        switch input.kind {
        case .send(let order):
            labelTitle.text = Localizable.Waves.Startleasingloading.Label.startLeasing
            startLeasing(order: order)

        case .cancel(let cancelOrder):
            labelTitle.text = Localizable.Waves.Startleasingloading.Label.cancelLeasing
            cancelLeasing(cancelOrder: cancelOrder)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        navigationItem.hidesBackButton = true
        navigationItem.backgroundImage = UIImage()
    }
    
    private func startLeasing(order: StartLeasingTypes.DTO.Order) {
        startLeasingInteractor
            .createOrder(order: order)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (transaction) in
            
                guard let owner = self else { return }

                let vc = StoryboardScene.StartLeasing.startLeasingCompleteViewController.instantiate()
                vc.kind = owner.input.kind
                owner.navigationController?.pushViewController(vc, animated: true)
                owner.input.output?.startLeasingDidSuccess(transaction: transaction, kind: owner.input.kind)

            }, onError: { [weak self] (error) in
                self?.popBackWithFail(error: NetworkError.error(by: error))
            })
            .disposed(by: disposeBag)
    }
    
    private func cancelLeasing(cancelOrder: StartLeasingTypes.DTO.CancelOrder) {
        
        cancelOrderRequest(cancelOrder: cancelOrder)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (transaction) in
            
                guard let owner = self else { return }

                let vc = StoryboardScene.StartLeasing.startLeasingCompleteViewController.instantiate()
                vc.kind = owner.input.kind
                owner.navigationController?.pushViewController(vc, animated: true)
                owner.input.output?.startLeasingDidSuccess(transaction: transaction, kind: owner.input.kind)

            }, onError: { [weak self] (error) in
                self?.popBackWithFail(error: NetworkError.error(by: error))
            })
            .disposed(by: disposeBag)
    }
    
    private func popBackWithFail(error: NetworkError) {
        input.errorDelegate?.startLeasingDidFail(error: error)
        navigationController?.popViewController(animated: true)
    }
    
    private func cancelOrderRequest(cancelOrder: StartLeasingTypes.DTO.CancelOrder) -> Observable<DomainLayer.DTO.SmartTransaction> {
        
        return authorization
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<DomainLayer.DTO.SmartTransaction> in

                guard let owner = self else { return Observable.empty() }
                let specific = CancelLeaseTransactionSender(leaseId: cancelOrder.leasingTX, fee: cancelOrder.fee.amount)
                return owner
                    .transactions
                    .send(by: .cancelLease(specific), wallet: wallet)
            })
    }
}
