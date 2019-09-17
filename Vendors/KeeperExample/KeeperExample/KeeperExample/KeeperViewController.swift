//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK
import TextFieldEffects
import RxSwift

class KeeperViewController: UIViewController {

    @IBOutlet private weak var textField: HoshiTextField!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var toolBar: UIToolbar!
    
    private var currentServer: Enviroment.Server!
    private var transaction: NodeService.Query.Transaction?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Keeper"
        
        pickerView.backgroundColor = .white
        toolBar.barTintColor = .white
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentServer = WavesSDK.shared.enviroment.server
        setupButton()
    }

    @IBAction private func selectPicker(_ sender: Any) {
        
        transaction = Transactions.list[pickerView.selectedRow(inComponent: 0)].type
        textField.text = Transactions.list[pickerView.selectedRow(inComponent: 0)].name
        
        textField.resignFirstResponder()
    }
    
    @IBAction private func dismissPicker(_ sender: Any) {
        textField.resignFirstResponder()
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
    
        if let tx = transaction {
            WavesKeeper.shared
                .send(tx)
                .subscribe(onNext: { [weak self] (response) in
                    
                    guard let self = self else { return }
                    print(response)
                    
                    }, onError: { [weak self] (error) in
                        
                        guard let self = self else { return }
                        
                        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        vc.addAction(cancel)
                        self.present(vc, animated: true, completion: nil)
                        
                }).disposed(by: disposeBag)
        }
    }
    
    @IBAction private func signTapped(_ sender: Any) {
    
        if let tx = transaction {
            WavesKeeper.shared
                .sign(tx)
                .subscribe(onNext: { [weak self] (response) in
                    
                    guard let self = self else { return }
                    print(response)
                    
                }, onError: { [weak self] (error) in
                    
                    guard let self = self else { return }
                    
                    let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    vc.addAction(cancel)
                    self.present(vc, animated: true, completion: nil)
                    
                }).disposed(by: disposeBag)
        }
    }
    
}

extension KeeperViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Transactions.list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Transactions.list[row].name
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

private extension KeeperViewController {
    func setupButton() {
        let buttonTitle = currentServer.isMainNet ? "MainNet" : "TestNet"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(changeNetwork))
    }
}
