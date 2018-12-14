//
//  TestSVGViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 14/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import SwiftSVG

final class TestSVGViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var models: [String] = ["https://raw.githubusercontent.com/wavesplatform/WavesWallet-iOS/feature/IOS-418/b-logos/Bettertokens.svg",
                            "https://raw.githubusercontent.com/wavesplatform/WavesWallet-iOS/feature/IOS-418/b-logos/manhammock.svg",
                            "https://raw.githubusercontent.com/wavesplatform/WavesWallet-iOS/feature/IOS-418/b-logos/Waves.svg",
                            "https://raw.githubusercontent.com/wavesplatform/WavesWallet-iOS/feature/IOS-418/b-logos/Waves%20Community%20Token.svg",
                            "https://raw.githubusercontent.com/wavesplatform/WavesWallet-iOS/feature/IOS-418/b-logos/Waves.svg",]
}

extension TestSVGViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Test", for: indexPath)

        let view: SVGView = cell.viewWithTag(666) as! SVGView

        let svgURL = URL(string: models[indexPath.row])!
        let hammock = UIView(SVGURL: svgURL) { (svgLayer) in
            svgLayer.resizeToFit(view.bounds)
        }
        hammock.frame = view.bounds

        view.addSubview(hammock)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 109
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
}
