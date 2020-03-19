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

    @IBOutlet private weak var buttonRetry: UIButton!
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
                        self?.setupLoadingState()
                    })
                   .flatMap { [weak self] (_) -> Observable<Bool> in
                       guard let self = self else { return Observable.never() }
                       return self
                           .developmentConfigsRepository
                           .isEnabledMaintenance()
                   }
                    .do(onError: { [weak self] _ in
                        self?.setupErrorState()
                    })
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { [weak self] isEnabledMaintenance in
                        guard let self = self else { return }
                        self.validateMaintenanceStatus(isEnabledMaintenance: isEnabledMaintenance)
                   })
                   .disposed(by: disposeBag)
    }
    
    private func setupLoadingState() {
        indicatorView.isHidden = false
        labelSubtitle.isHidden = true
        buttonRetry.isEnabled = false
    }
    
    private func setupErrorState() {
        indicatorView.isHidden = true
        labelSubtitle.isHidden = false
        buttonRetry.isEnabled = true
    }
    
    private func validateMaintenanceStatus(isEnabledMaintenance: Bool) {
        indicatorView.isHidden = true
        labelSubtitle.isHidden = false
        buttonRetry.isEnabled = true
        if isEnabledMaintenance == false {
            delegate?.serverMaintenanceDisabled()
        }
    }
    
    @IBAction private func retryTapped(_ sender: Any) {
        setupLoadingState()
        developmentConfigsRepository
        .isEnabledMaintenance()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabledMaintenance in
                guard let self = self else { return }
                self.validateMaintenanceStatus(isEnabledMaintenance: isEnabledMaintenance)

            }, onError: { [weak self] _ in
                self?.setupErrorState()

            }).disposed(by: disposeBag)
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Servermaintenance.Label.title
        labelSubtitle.text = Localizable.Waves.Servermaintenance.Label.subtitle
        buttonRetry.setTitle(Localizable.Waves.Servermaintenance.Button.retry, for: .normal)
    }
}
