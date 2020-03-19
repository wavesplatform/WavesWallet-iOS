//
//  ReceiveAddressViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import QRCode
import RxSwift
import DataLayer
import Extensions

private enum Constants {
    static let copyDuration: TimeInterval = 2
}

protocol ReceiveAddressViewControllerModuleOutput: AnyObject {
    
    func receiveAddressDidShowInfo()
    func receiveAddressDidTapClose()
    func receiveAddressDidTapShare(address: String)
}

final class ReceiveAddressViewController: UIViewController {
        
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var receiveAddressView: ReceiveAddressView {
        return view as! ReceiveAddressView
    }

    weak var moduleOutput: ReceiveAddressViewControllerModuleOutput?
    
    var moduleInput: ReceiveAddress.ViewModel.DisplayData? {
        didSet {
            guard let moduleInput = moduleInput else { return }
            title = Localizable.Waves.Receiveaddress.Label.yourAddress(moduleInput.address.assetName)
            receiveAddressView.update(with: moduleInput.address)
            if moduleInput.hasShowInfo {
                createInfoButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiveAddressView.delegate = self
        createCancelButton()
        removeTopBarLine()
        
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func createCancelButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Images.topbarClosewhite.image, style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    private func createInfoButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarInfowhite.image, style: .plain, target: self, action: #selector(infoTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
        
    @objc private func infoTapped() {
        moduleOutput?.receiveAddressDidShowInfo()
    }
        
    @objc private func cancelTapped() {
        moduleOutput?.receiveAddressDidTapClose()
    }
}

// MARK: ReceiveAddressViewDelegate

extension ReceiveAddressViewController: ReceiveAddressViewDelegate {
    
    func closeTapped() {
        cancelTapped()
    }
        
    func sharedTapped(_ info: ReceiveAddress.ViewModel.Address) {
        moduleOutput?.receiveAddressDidTapShare(address: info.address)
    }
}

private extension Array where Element == ReceiveAddress.ViewModel.Address {
    
    var assetName: String {
        return self.first?.assetName ?? ""
    }
}
