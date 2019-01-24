//
//  StartLeasingConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 2
}

final class StartLeasingConfirmationViewController: UIViewController {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var tickerView: TickerView!
    @IBOutlet private weak var labelNodeAddressTitle: UILabel!
    @IBOutlet private weak var labelNodeAddress: UILabel!
    @IBOutlet private weak var labelFeeTitle: UILabel!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var buttonConfirm: HighlightedButton!
    
    var order: StartLeasingTypes.DTO.Order!
    weak var output: StartLeasingModuleOutput?
    weak var errorDelegate: StartLeasingErrorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        createBackWhiteButton()
        setupLocalization()
        setupData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        setupBigNavigationBar()
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewContainer.createTopCorners(radius: Constants.cornerRadius)
    }
    
    @IBAction private func confirmTapped(_ sender: Any) {
        
        let vc = StoryboardScene.StartLeasing.startLeasingLoadingViewController.instantiate()
        vc.input = .init(kind: .send(order), errorDelegate: errorDelegate, output: output)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupData() {
        tickerView.update(with: .init(text: GlobalConstants.wavesAssetId, style: .soft))
        labelAmount.text = order.amount.displayText
        labelNodeAddress.text = order.recipient
        labelFee.text = order.fee.displayText
    }
    
    private func setupLocalization() {
        title = Localizable.Waves.Startleasingconfirmation.Label.confirmation
        labelNodeAddressTitle.text = Localizable.Waves.Startleasingconfirmation.Label.nodeAddress
        labelFeeTitle.text = Localizable.Waves.Startleasingconfirmation.Label.fee
        buttonConfirm.setTitle(Localizable.Waves.Startleasingconfirmation.Button.confirm, for: .normal)
    }
}
