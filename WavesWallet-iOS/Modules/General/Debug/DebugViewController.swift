//
//  SupportViewControllerV2.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Crashlytics
import DomainLayer
import Extensions
import Foundation
import UIKit
import UITools

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
        case test(_ isOn: Bool)
        case stageSwitch(_ isOn: Bool)
        case info(_ version: String, _ deviceId: String)
        case crash
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

    private var environmentRepository: EnvironmentRepositoryProtocol = UseCasesFactory.instance.repositories.environmentRepository

    var delegate: DebugViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Debug"
        setupBigNavigationBar()
        removeTopBarLine()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(handlerDoneButton))
    }

    @objc private func handlerDoneButton() {
        delegate?.dissmissDebugVC(isNeedRelaunchApp: isNeedRelaunchApp)
    }
}

// MARK: UITableViewDelegate

extension DebugViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        ProfileHeaderView.viewHeight()
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

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = displayState[indexPath]

        switch row {
        case .enviroments:
            return DebugEnviromentsCell.cellHeight()

        case .stageSwitch,
             .test,
             .crash:
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
        case .crash:
            let cell: DebugSwitchCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Crash",
                                    isOn: false))

            cell.switchChangedValue = { _ in
                Crashlytics.sharedInstance().crash()
            }

            return cell

        case let .test(isOn):

            let cell: DebugSwitchCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Test settings",
                                    isOn: isOn))

            cell.switchChangedValue = { isOn in
                ApplicationDebugSettings.setEnableEnviromentTest(isEnable: isOn)
            }

            return cell

        case let .stageSwitch(isOn):

            let cell: DebugSwitchCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Enable Stage (Need?)",
                                    isOn: isOn))

            cell.switchChangedValue = { isOn in

                ApplicationDebugSettings.setupIsEnableStage(isEnable: isOn)
            }
            return cell

        case let .enviroments(envriroments, current):

            let cell: DebugEnviromentsCell = tableView.dequeueCell()
            cell.update(with: DebugEnviromentsCell.Model(chainId: current.chainId, name: current.name))

            cell.buttonDidTap = { [weak self] in
                self?.pickEnvriroments(envriroments, current: current)
            }
            return cell

        case let .info(version, deviceId):
            let cell: DebugInfoCell = tableView.dequeueCell()

            cell.update(with: DebugInfoCell.Model(version: version,
                                                  deviceId: deviceId))
            cell.deleteButtonDidTap = { [weak self] in
                self?.deleteAllData()
            }

            return cell
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayState[section].rows.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        displayState.sections.count
    }
}

private extension DebugViewController {
    func pickEnvriroments(_ envriroments: [Debug.Enviroment], current: Debug.Enviroment) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancel)

        for value in envriroments {
            let action = UIAlertAction(title: value.name, style: .default) { [weak self] _ in
                self?.changeEnviroment(value)
            }

            action.isEnabled = current.chainId != value.chainId
            controller.addAction(action)
        }

        present(controller, animated: true, completion: nil)
    }

    func changeEnviroment(_ enviroment: Debug.Enviroment) {
        let kind = WalletEnvironment.Kind(rawValue: enviroment.chainId) ?? .mainnet

        environmentRepository.environmentKind = kind

        isNeedRelaunchApp = true
        displayState = createDisplaState()
        tableView.reloadData()
    }

    func createDisplaState() -> Debug.DisplayState {
        let version = Bundle.main.versionAndBuild

        let isEnableStage = ApplicationDebugSettings.isEnableStage
                
        let isEnableEnviromentTest = ApplicationDebugSettings.isEnableEnviromentTest

        let mainNet: Debug.Enviroment = .init(name: "Mainnet",
                                              chainId: "W")

        let testNet: Debug.Enviroment = .init(name: "Testnet",
                                              chainId: "T")

        let wxdevnet: Debug.Enviroment = .init(name: "WXDevnet",
                                               chainId: "S")
        
        let stagenet: Debug.Enviroment = .init(name: "Stagenet",
                                               chainId: "S")

        var current: Debug.Enviroment!

        switch environmentRepository.environmentKind {
        case .mainnet:
            current = mainNet

        case .wxdevnet:
            current = wxdevnet

        case .testnet:
            current = testNet
        }

        let sections: [Debug.Section] = [.init(rows: [Debug.Row.enviroments([mainNet,
                                                                             testNet,
                                                                             wxdevnet],
                                                                            current),
                                                        .test(isEnableEnviromentTest)],
                                               kind: .enviroment),
                                         .init(rows: [.crash,
                                                      .stageSwitch(isEnableStage),
                                                      
                                                      .info(version, UIDevice.uuid)],
                                               kind: .other)]

        let state = Debug.DisplayState(sections: sections)
        return state
    }

    func deleteAllData() {
        delegate?.relaunchApplication()

        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let trashDirectory = NSSearchPathForDirectoriesInDomains(.trashDirectory, .userDomainMask, true)
        let userDirectory = NSSearchPathForDirectoriesInDomains(.userDirectory, .userDomainMask, true)

        var paths: [String] = []

        paths.append(contentsOf: documentDirectory)
        paths.append(contentsOf: cachesDirectory)
        paths.append(contentsOf: trashDirectory)
        paths.append(contentsOf: userDirectory)

        paths.forEach { file in
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
                }
            }
        } catch {
        }
    }
}
