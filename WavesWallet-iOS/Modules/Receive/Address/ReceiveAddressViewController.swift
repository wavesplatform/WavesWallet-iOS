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

final class ReceiveAddressViewController: UIViewController {
    
    struct Model {
        let assetName: String
        let addressesInfo: [ReceiveAddress.DTO.Info]    
    }
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var receiveAddressView: ReceiveAddressView {
        return view as! ReceiveAddressView
    }
    
    var moduleInput: [ReceiveAddress.DTO.Info]? {
        didSet {
            title = Localizable.Waves.Receiveaddress.Label.yourAddress(moduleInput?.first?.assetName ?? "")
            receiveAddressView.update(with: moduleInput ?? [])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        receiveAddressView.delegate = self
        createBackWhiteButton()
        createCancelButton()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backgroundImage = UIImage()
        removeTopBarLine()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    private func createCancelButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarInfowhite.image, style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func infoTapped() {
       //TODO:
    }
    
    
    //TODO: Coordinator
    @objc private func cancelTapped() {
        if let assetVc = navigationController?.viewControllers.first(where: {$0.classForCoder == AssetDetailViewController.classForCoder()}) {
            navigationController?.popToViewController(assetVc, animated: true)
        }
        else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ReceiveAddressViewController: ReceiveAddressViewDelegate {
    
    func closeTapped() {
        cancelTapped()
    }
    
    //TODO: Coordinator
    func sharedTapped(_ info: ReceiveAddress.DTO.Info) {
        
        let activityVC = UIActivityViewController(activityItems: [info.address], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
}
