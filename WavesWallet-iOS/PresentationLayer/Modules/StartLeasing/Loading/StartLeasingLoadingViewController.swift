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
    
    var kind: StartLeasingTypes.Kind!
    weak var delegate: StartLeasingErrorDelegate?
    
    private let startLeasingInteractor: StartLeasingInteractorProtocol = StartLeasingInteractor()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        switch kind! {
        case .send(let order):
            labelTitle.text = Localizable.Waves.Startleasingloading.Label.startLeasing
            startLeasing(order: order)

        case .cancel:
            labelTitle.text = Localizable.Waves.Startleasingloading.Label.cancelLeasing
            cancelLeasing()
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
        
        startLeasingInteractor.createOrder(order: order).subscribe(onNext: { [weak self] (success) in
            
            if success {
                
            }
            else {
                self?.popBackWithFail()
            }
            
        }, onError: { [weak self] (error) in
            self?.popBackWithFail()
        }).disposed(by: disposeBag)
    }
    
    private func cancelLeasing() {
        
    }
    
    private func popBackWithFail() {
        delegate?.startLeasingDidFail()
        navigationController?.popViewController(animated: true)
    }
}
