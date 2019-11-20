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
                
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol = UseCasesFactory.instance.repositories.developmentConfigsRepository
    private let disposeBag: DisposeBag = DisposeBag()
    
    weak var delegate: ServerMaintenanceViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
        
        NotificationCenter
            .default
            .rx
            .notification(UIApplication.willEnterForegroundNotification,
                          object: nil)
            .flatMap { [weak self] (_) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self
                    .developmentConfigsRepository
                    .isEnabledMaintenance()
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabledMaintenance in
                guard let self = self else { return }
                if isEnabledMaintenance == false {
                    self.delegate?.serverMaintenanceDisabled()
                }
            })
            .disposed(by: disposeBag)
                       
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Servermaintenance.Label.title
        labelSubtitle.text = Localizable.Waves.Servermaintenance.Label.subtitle
    }
}
