//
//  StartLeasingCancelConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class StartLeasingCancelConfirmationViewController: UIViewController {

    @IBOutlet private weak var buttonCancel: HighlightedButton!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var tickerView: TickerView!
    @IBOutlet private weak var labelTxTitle: UILabel!
    @IBOutlet private weak var labelTx: UILabel!
    @IBOutlet private weak var labelIDTItle: UILabel!
    @IBOutlet private weak var labelID: UILabel!
    @IBOutlet private weak var labelFeeTitle: UILabel!
    @IBOutlet private weak var labelFee: UILabel!
    
    var cancelOrder: StartLeasingTypes.DTO.CancelOrder!

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
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    private func setupData() {
        tickerView.update(with: .init(text: GlobalConstants.wavesAssetId, style: .soft))
        labelAmount.text = cancelOrder.amount.displayText
        labelID.text = cancelOrder.id
        labelTx.text = cancelOrder.tx
        labelFee.text = cancelOrder.fee.displayText
    }
    
    private func setupLocalization() {
        title = Localizable.Waves.Startleasingconfirmation.Label.confirmation
        labelTxTitle.text = Localizable.Waves.Startleasingconfirmation.Label.leasingTX
        labelIDTItle.text = Localizable.Waves.Startleasingconfirmation.Label.txid
        labelFeeTitle.text = Localizable.Waves.Startleasingconfirmation.Label.fee + " " + "WAVES"
    }
    
    @IBAction private func cancelLeasing(_ sender: Any) {
    
        let vc = StartLeasingLoadingBuilder().build(input: .init(kind: .cancel(cancelOrder), delegate: self))
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - StartLeasingErrorDelegate
extension StartLeasingCancelConfirmationViewController: StartLeasingErrorDelegate {
    func startLeasingDidFail() {
        //TODO: need to show error
    }
}
