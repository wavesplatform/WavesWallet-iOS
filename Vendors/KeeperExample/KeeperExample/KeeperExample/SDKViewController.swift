//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK
import RxSwift

final class SDKViewController: UIViewController {

    private var currentServer: Enviroment.Server = .mainNet
    @IBOutlet private weak var labelInfo: UILabel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "My Waves dApp"
        setupButton()
        labelInfo.text = "Example"
        WavesSDK.initialization(servicesPlugins: .init(data: [], node: [], matcher: []), enviroment: .init(server: currentServer, timestampServerDiff: 0))
    }

    @IBAction private func generateNewSeed(_ sender: Any) {
        let seed = WordList.generatePhrase()
        let privateKey = PrivateKeyAccount(seedStr: seed)
        
        self.setupInfo(title: "New seed is:", value: privateKey.words.joined(separator: " "))
    }
    
    @IBAction private func loadWavesBalance(_ sender: Any) {
        
        let privateKey = PrivateKeyAccount(seedStr: "")
        
        WavesSDK.shared.services.nodeServices
        .addressesNodeService
        .addressBalance(address: privateKey.address)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (balance) in
                
                guard let self = self else { return }
                
                self.setupInfo(title: "Balance is:", value: String(balance.balance))
            }).disposed(by: disposeBag)
        
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
}

private extension SDKViewController {
    
    func setupInfo(title: String, value: String) {
        
        let text = title + " " + value
        
        let attr = NSMutableAttributedString(string: text)
        attr.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: labelInfo.font.pointSize)],
                           range: (text as NSString).range(of: title))
        labelInfo.attributedText = attr
    }
    
    func setupButton() {
        let buttonTitle = currentServer.isMainNet ? "MainNet" : "TestNet"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(changeNetwork))
    }
}

private extension Enviroment.Server {
    var isMainNet: Bool {
        switch self {
        case .mainNet:
            return true
        default:
            return false
        }
    }
}
