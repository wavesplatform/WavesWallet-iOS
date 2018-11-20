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
    
    var kind: StartLeasing.Kind!
    weak var delegate: StartLeasingDelegate?
    
    private let startLeasingInteractor: StartLeasingInteractorProtocol = StartLeasingInteractor()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        switch kind {
//        case .send(let order):
//            labelTitle.text = Localizable.Waves.Startleasingloading.Label.startLeasing
//            startLeasing(order: order)
//
//        case .cancel:
//            labelTitle.text = Localizable.Waves.Startleasingloading.Label.cancelLeasing
//            cancelLeasing()
//        }
    }
    
    private func startLeasing(order: StartLeasing.DTO.Order) {
        
        startLeasingInteractor.createOrder(order: order).subscribe(onNext: { (success) in
            
        }, onError: { [weak self] (error) in
            self?.delegate?.startLeasingDidFail(error: error)
            
            if let vc = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: StartLeasingViewController.classForCoder())}) {
                self?.navigationController?.popToViewController(vc, animated: true)
            }
            else {
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    private func cancelLeasing() {
        
    }
    
}
