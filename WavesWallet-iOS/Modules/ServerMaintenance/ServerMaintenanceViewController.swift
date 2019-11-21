//
//  ForceUpdateAppViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 01.11.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import WavesSDK
import DomainLayer

protocol ServerMaintenanceViewControllerDelegate: AnyObject {
    
    func serverMaintenanceDisabled()
}

final class ServerMaintenanceViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
                
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol = UseCasesFactory.instance.repositories.developmentConfigsRepository
    private let disposeBag: DisposeBag = DisposeBag()
    
    weak var delegate: ServerMaintenanceViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
        
        self.indicatorView.startAnimating()
        self.indicatorView.isHidden = true
        
        NotificationCenter
                   .default
                   .rx
                   .notification(UIApplication.willEnterForegroundNotification,
                                 object: nil)
                    .do(onNext: { [weak self] _ in
                        self?.indicatorView.isHidden = false
                        self?.labelSubtitle.isHidden = true
                    })
                   .flatMap { [weak self] (_) -> Observable<Bool> in
                       guard let self = self else { return Observable.never() }
                       return self
                           .developmentConfigsRepository
                           .isEnabledMaintenance()
                   }
                    .do(onError: { [weak self] _ in
                        self?.indicatorView.isHidden = true
                        self?.labelSubtitle.isHidden = false
                    })
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { [weak self] isEnabledMaintenance in
                       guard let self = self else { return }
                    
                        self.indicatorView.isHidden = true
                        self.labelSubtitle.isHidden = false
                        print("NotificationCenter \(isEnabledMaintenance)")
                       if isEnabledMaintenance == false {
                           self.delegate?.serverMaintenanceDisabled()
                       }
                   })
                   .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Servermaintenance.Label.title
        labelSubtitle.text = Localizable.Waves.Servermaintenance.Label.subtitle
    }
}
