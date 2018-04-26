//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletTableCell: UITableViewCell {
    
}

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  
    //MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableCell") as! WalletTableCell
        
        return cell
    }

}
