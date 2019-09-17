//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK

class KeeperViewController: UIViewController {

    private var currentServer: Enviroment.Server = .mainNet
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Keeper"
        setupButton()
        WavesSDK.initialization(servicesPlugins: .init(data: [], node: [], matcher: []), enviroment: .init(server: currentServer, timestampServerDiff: 0))
    }

    @objc private func changeNetwork() {
        if currentServer.isMainNet {
            currentServer = .testNet
        }
        else {
            currentServer = .mainNet
        }
        setupButton()
        WavesSDK.initialization(servicesPlugins: .init(data: [], node: [], matcher: []), enviroment: .init(server: currentServer, timestampServerDiff: 0))
    }
    
    @IBAction private func sendTapped(_ sender: Any) {
    
    }
    
    @IBAction private func signTapped(_ sender: Any) {
    
    }
    
}

private extension KeeperViewController {
    func setupButton() {
        let buttonTitle = currentServer.isMainNet ? "MainNet" : "TestNet"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(changeNetwork))
    }
}
