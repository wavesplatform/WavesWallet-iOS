//
//  SupportViewControllerV2.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import DomainLayer

enum Debug {

    struct DisplayState: DataSourceProtocol {
        var sections: [Section]
    }
}

extension Debug {
    
    struct Enviroment {
        let name: String
        let chainId: String
    }
    
    enum Row {
        case enviroments(_ enviroments: [Enviroment], _ current: Enviroment)
        case stageSwitch(_ isOn: Bool)
        case notificationDevSwitch(_ isOn: Bool)
        case info(_ version: String, _ deviceId: String)
    }
    
    struct Section: SectionProtocol {
        
        enum Kind {
            case enviroment
            case other
        }
        
        var rows: [Row]
        var kind: Kind
    }
}

protocol DebugViewControllerDelegate: AnyObject {
    
    func dissmissDebugVC(isNeedRelaunchApp: Bool)
    
    func relaunchApplication()
}

final class DebugViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var displayState: Debug.DisplayState = createDisplaState()
    
    private var isNeedRelaunchApp: Bool = false
    
    var delegate: DebugViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Debug"
        setupBigNavigationBar()
        hideTopBarLine()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                                     target: self,
                                                                     action: #selector(handlerDoneButton))
    }
    
    @objc private func handlerDoneButton() {
        self.delegate?.dissmissDebugVC(isNeedRelaunchApp: isNeedRelaunchApp)
    }
}

// MARK: UITableViewDelegate

extension DebugViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProfileHeaderView.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view: ProfileHeaderView = tableView.dequeueAndRegisterHeaderFooter()
        
        let section = displayState[section]
        
        switch section.kind {
        case .enviroment:
            view.update(with: "Enviroment")
            
        case .other:
            view.update(with: "Other")
            
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = displayState[indexPath]
        
        switch row {
        case .enviroments:
            return DebugEnviromentsCell.cellHeight()
            
        case .stageSwitch,
             .notificationDevSwitch:
            return DebugSwitchCell.cellHeight()
            
        case .info:
            return DebugInfoCell.cellHeight()
        }
    }
}

// MARK: UITableViewDataSource

extension DebugViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = displayState[indexPath]
        
        switch row {
        case .stageSwitch(let isOn):
            
            let cell: DebugSwitchCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Enable Stage",
                                    isOn: isOn))
            
            cell.switchChangedValue = { isOn in
                ApplicationDebugSettings.setupIsEnableStage(isEnable: isOn)
            }
            return cell
            
        case .notificationDevSwitch(let isOn):
            
            let cell: DebugSwitchCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Notification Dev",
                                    isOn: isOn))
            
            cell.switchChangedValue = { isOn in
                ApplicationDebugSettings.setEnableNotificationsSettingDev(isEnable: isOn)
            }
            return cell
            
        case .enviroments(let envriroments, let current):
            
            let cell: DebugEnviromentsCell = tableView.dequeueCell()
            cell.update(with: DebugEnviromentsCell.Model(chainId: current.chainId, name: current.name))
            
            cell.buttonDidTap = { [weak self] in
                self?.pickEnvriroments(envriroments, current: current)
            }
            return cell

        case .info(let version, let deviceId):
            let cell: DebugInfoCell = tableView.dequeueCell()
            
            cell.update(with: DebugInfoCell.Model.init(version: version,
                                                       deviceId: deviceId))
            cell.deleteButtonDidTap = { [weak self] in
                self?.deleteAllData()
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayState[section].rows.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return displayState.sections.count
    }
}

private extension DebugViewController {
    
    func pickEnvriroments(_ envriroments: [Debug.Enviroment], current: Debug.Enviroment) {

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancel)
        
        for value in envriroments {
            
            let action = UIAlertAction(title: value.name, style: .default) { [weak self] (action) in
                self?.changeEnviroment(value)
            }
            
            action.isEnabled = current.chainId != value.chainId
            controller.addAction(action)
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func changeEnviroment(_ enviroment: Debug.Enviroment) {
        
        if enviroment.chainId == "W" {
            WalletEnvironment.isTestNet = false
        } else {
            WalletEnvironment.isTestNet = true
        }
        
        self.isNeedRelaunchApp = true
        self.displayState = createDisplaState()
        self.tableView.reloadData()
    }
    
    func createDisplaState() -> Debug.DisplayState {
        
        let version = Bundle.main.versionAndBuild
        
        let isEnableStage = ApplicationDebugSettings.isEnableStage
        let isEnableNotificationsSettingDev = ApplicationDebugSettings.isEnableNotificationsSettingDev
        
        
        let mainNet: Debug.Enviroment = .init(name: "Mainnet",
                                              chainId: "W")
        
        let testNet: Debug.Enviroment = .init(name: "Testnet",
                                              chainId: "T")
        
        var current: Debug.Enviroment! = nil
        
        if WalletEnvironment.isTestNet {
            current = testNet
        } else {
            current = mainNet
        }
        
        let sections: [Debug.Section] = [.init(rows: [Debug.Row.enviroments([mainNet, testNet],
                                                                            current)],
                                               kind: .enviroment),
                                         .init(rows: [.stageSwitch(isEnableStage),
                                                      .notificationDevSwitch(isEnableNotificationsSettingDev),
                                                      .info(version, UIDevice.uuid)],
                                               kind: .other)]
        
        let state = Debug.DisplayState(sections: sections)
        
        
        return state
    }
    
    func deleteAllData() {
        
        self.delegate?.relaunchApplication()
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let trashDirectory = NSSearchPathForDirectoriesInDomains(.trashDirectory, .userDomainMask, true)
        let userDirectory = NSSearchPathForDirectoriesInDomains(.userDirectory, .userDomainMask, true)
        
        var paths: [String] = []
        
        paths.append(contentsOf: documentDirectory)
        paths.append(contentsOf: cachesDirectory)
        paths.append(contentsOf: trashDirectory)
        paths.append(contentsOf: userDirectory)
        
        paths.forEach { (file) in
            clearFolder(tempFolderPath: file)
        }
    }
    
    func clearFolder(tempFolderPath: String) {
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                do {
                    try fileManager.removeItem(atPath: tempFolderPath + "/" + filePath)
                } catch {
                    print("remove item: \(error)")
                }
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}
