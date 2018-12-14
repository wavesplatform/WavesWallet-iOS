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
    var models: [String] = [String]()
}

extension TestSVGViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Test", for: indexPath)
//        let imageView

        let view: SVGView = cell.viewWithTag(666) as! SVGView
        view.SVGName = 
        

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
}
