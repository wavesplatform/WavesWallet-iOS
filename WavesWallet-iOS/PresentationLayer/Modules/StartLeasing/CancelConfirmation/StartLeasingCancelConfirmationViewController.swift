//
//  StartLeasingCancelConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 2
}

final class StartLeasingCancelConfirmationViewController: UIViewController {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var buttonCancel: HighlightedButton!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var tickerView: TickerView!
    @IBOutlet private weak var labelLeasingTxTitle: UILabel!
    @IBOutlet private weak var labelLeasingTx: UILabel!
    @IBOutlet private weak var labelFeeTitle: UILabel!
    @IBOutlet private weak var labelFee: UILabel!
    
    var cancelOrder: StartLeasingTypes.DTO.CancelOrder!
    weak var output: StartLeasingModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackWhiteButton()
        setupLocalization()
        setupData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewContainer.createTopCorners(radius: Constants.cornerRadius)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        setupBigNavigationBar()
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    private func setupData() {
        tickerView.update(with: .init(text: GlobalConstants.wavesAssetId, style: .soft))
        labelAmount.text = cancelOrder.amount.displayText
        labelLeasingTx.text = cancelOrder.leasingTX
        labelFee.text = cancelOrder.fee.displayText
    }
    
    private func setupLocalization() {
        title = Localizable.Waves.Startleasingconfirmation.Label.confirmation
        labelLeasingTxTitle.text = Localizable.Waves.Startleasingconfirmation.Label.leasingTX
        labelFeeTitle.text = Localizable.Waves.Startleasingconfirmation.Label.fee + " " + "WAVES"
    }
    
    @IBAction private func cancelLeasing(_ sender: Any) {
    
        let vc = StoryboardScene.StartLeasing.startLeasingLoadingViewController.instantiate()
        vc.input = .init(kind: .cancel(cancelOrder), errorDelegate: self, output: output)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - StartLeasingErrorDelegate
extension StartLeasingCancelConfirmationViewController: StartLeasingErrorDelegate {
    func startLeasingDidFail(error: NetworkError) {
        showNetworkErrorSnack(error: error)
    }
}
