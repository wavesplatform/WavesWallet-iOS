//
//  TradeViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import WavesSDK

private enum Constants {
    static let btcTitle = "BTC"
}

final class TradeViewController: UIViewController {

    @IBOutlet private weak var scrolledTableView: ScrolledContainerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Waves.Trade.title

        let image = NewSegmentedControl.SegmentedItem.image(.init(unselected: Images.iconFavEmpty.image, selected: Images.favorite14Submit300.image))
        let segmentedTitles = [Constants.btcTitle, WavesSDKConstants.wavesAssetId, Localizable.Waves.Trade.Segment.alts, Localizable.Waves.Trade.Segment.fiat]
        scrolledTableView.setup(segmentedItems: [image] + segmentedTitles.map { .title($0)}, tableDataSource: self, tableDelegate: self)
    }
}

//MARK: - UITableViewDelegate
extension TradeViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension TradeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        if tableView.tag == 3 {
            let view = tableView.dequeueAndRegisterHeaderFooter() as TradeAltsHeaderView
        view.update(with: ["ETH", "LTC", "XMR", "TYU", "ZTC"])
        return view
//        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

//        if tableView.tag == 3 {
            return TradeAltsHeaderView.viewHeight()
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeTableViewCell.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueAndRegisterCell() as TradeTableViewCell
        cell.test()
        return cell
    }
}
