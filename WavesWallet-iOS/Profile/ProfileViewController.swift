//
//  ProfileViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu


class ProfileBottomCell: UITableViewCell {

    @IBOutlet weak var buttonDelete: UIButton!
    
    class func cellHeight() -> CGFloat {
        return 200
    }
}

class ProfileBackupPhraseCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewColorState: UIView!
    @IBOutlet weak var iconState: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    
        let maskPath = UIBezierPath(roundedRect: viewColorState.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 3, height: 3))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        viewColorState.layer.mask = shape
    }
}


class ProfilePushTableCell: UITableViewCell {
 
}

class ProfileTableCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLang: UIImageView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var iconArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return 56
    }
    
    @IBAction func switchChanged(_ sender: Any) {
    
        if BiometricManager.type == .none {

            firstAvailableViewController().presentBasicAlertWithTitle(title: "Please setup your \(BiometricManager.touchIDTypeText)")
            DataManager.setUseTouchID(false)
            DispatchQueue.main.async {
                self.switchControl.isOn = false
            }
        }
        else {
            DataManager.setUseTouchID(switchControl.isOn)
        }
    }
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum GeneralSection: Int {
        case addressesAndKeys = 0
        case addressBook
        case push
        case language
    }
    
    enum SecuritySection: Int {
        case backupPhrase = 0
        case changePassword
        case changePasscode
        case touchID
        case network
    }
    
    enum OtherSection: Int {
        case rateApp = 0
        case feedback
        case supportWavesplatform
        case bottomRow
    }
    
    
    enum ProfileSection: Int {
        case general = 0
        case security
        case other
    }
    
    let generalNames = ["Addresses and keys", "Address book", "Push Notifications", "Language"]
    let securityNames = ["Backup phrase", "Change password", "Change passcode", "Touch ID", "Network"]
    let otherNames = ["Rate app", "Feedback", "Support Wavesplatform", ""]
    
    var lastScrollCorrectOffset: CGPoint?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMenuButton()
        title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "topbarLogout"), style: .plain, target: self, action: #selector(logoutTapped))
        tableView.register(UINib(nibName: WalletHeaderView.identifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: WalletHeaderView.identifier())
    }

    override func viewDidAppear(_ animated: Bool) {
        lastScrollCorrectOffset = nil
    }
    
    func setupLastScrollCorrectOffset() {
        lastScrollCorrectOffset = tableView.contentOffset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupBigNavigationBar()
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    
        if rdv_tabBarController.isTabBarHidden {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
    }
    
    @objc func logoutTapped() {
        
        let enter = StoryboardManager.EnterStoryboard().instantiateViewController(withIdentifier: "EnterStartViewController") as! EnterStartViewController
        let nav = UINavigationController(rootViewController: enter)
        AppDelegate.shared().menuController.setContentViewController(nav, animated: true)
    }
    
    @objc func deleteAccountTapped() {

        let hasSeed = false
        
        if hasSeed {
            let controller = storyboard?.instantiateViewController(withIdentifier: "DeleteAccountViewController") as! DeleteAccountViewController
            
            controller.showInController(rdv_tabBarController)
        }
        else {
            let controller = UIAlertController(title: "Delete account", message: "Are you sure you want to delete this account from device?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let delete = UIAlertAction(title: "Delete", style: .default) { (action) in
                
            }
            controller.addAction(cancel)
            controller.addAction(delete)
            present(controller, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == ProfileSection.general.rawValue {

            if indexPath.row == GeneralSection.addressesAndKeys.rawValue {
                
                setupLastScrollCorrectOffset()
                let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileAddressKeyViewController") as! ProfileAddressKeyViewController
                navigationController?.pushViewController(controller, animated: true)
                rdv_tabBarController.setTabBarHidden(true, animated: true)
            }
            else if indexPath.row == GeneralSection.addressBook.rawValue {

                setupLastScrollCorrectOffset()
                let controller = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "ChooseAddressBookViewController") as! ChooseAddressBookViewController
                controller.isEditMode = true
                navigationController?.pushViewController(controller, animated: true)
                rdv_tabBarController.setTabBarHidden(true, animated: true)
            }
            else if indexPath.row == GeneralSection.language.rawValue {
                
                setupLastScrollCorrectOffset()
                let controller = storyboard?.instantiateViewController(withIdentifier: "LanguageViewController") as! LanguageViewController
                navigationController?.pushViewController(controller, animated: true)
                rdv_tabBarController.setTabBarHidden(true, animated: true)
            }            
        }
        else if indexPath.section == ProfileSection.security.rawValue {
            
            if indexPath.row == SecuritySection.changePassword.rawValue {
                
                setupLastScrollCorrectOffset()
                let controller = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                navigationController?.pushViewController(controller, animated: true)
                rdv_tabBarController.setTabBarHidden(true, animated: true)
            }
            else if indexPath.row == SecuritySection.changePasscode.rawValue {
                
                setupLastScrollCorrectOffset()
                let controller = storyboard?.instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
                navigationController?.pushViewController(controller, animated: true)
                rdv_tabBarController.setTabBarHidden(true, animated: true)
            }
            else if indexPath.row == SecuritySection.network.rawValue {
                
                setupLastScrollCorrectOffset()
                let controller = storyboard?.instantiateViewController(withIdentifier: "NetworkViewController") as! NetworkViewController
                navigationController?.pushViewController(controller, animated: true)
                rdv_tabBarController.setTabBarHidden(true, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let offset = lastScrollCorrectOffset, Platform.isIphoneX {
            scrollView.contentOffset = offset // to fix top bar offset in iPhoneX when tabBarHidden = true
        }
        setupTopBarLine()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return WalletHeaderView.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletHeaderView.identifier()) as! WalletHeaderView

        view.labelTitle.textColor = .disabled500
        view.iconArrow.isHidden = true
        
        if section == ProfileSection.general.rawValue {
            view.labelTitle.text = "General settings"
        }
        else if section == ProfileSection.security.rawValue {
            view.labelTitle.text = "Security"
        }
        else if section == ProfileSection.other.rawValue {
            view.labelTitle.text = "Other"
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.section == ProfileSection.general.rawValue {
            if indexPath.row == generalNames.count - 1 {
                return ProfileTableCell.cellHeight() + 10
            }
        }
        else if indexPath.section == ProfileSection.security.rawValue {
            if indexPath.row == securityNames.count - 1 {
                return ProfileTableCell.cellHeight() + 10
            }
        }
        else if indexPath.section == ProfileSection.other.rawValue {
            if indexPath.row == OtherSection.bottomRow.rawValue {
                return ProfileBottomCell.cellHeight()
            }
        }
        
        return ProfileTableCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if section == ProfileSection.general.rawValue {
            return generalNames.count
        }
        else if section == ProfileSection.security.rawValue {
            return securityNames.count
        }
        else if section == ProfileSection.other.rawValue {
            return otherNames.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == ProfileSection.general.rawValue && indexPath.row == GeneralSection.push.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePushTableCell") as! ProfilePushTableCell
            return cell
        }
        else if indexPath.section == ProfileSection.security.rawValue && indexPath.row == SecuritySection.backupPhrase.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileBackupPhraseCell") as! ProfileBackupPhraseCell
            
            let isSuccess = false
            if isSuccess {
                cell.iconState.image = UIImage(named: "check_success")
                cell.viewColorState.backgroundColor = .success400
            }
            else {
                cell.iconState.image = UIImage(named: "info18Error500")
                cell.viewColorState.backgroundColor = .error500
            }
            return cell
        }
        else if indexPath.section == ProfileSection.other.rawValue && indexPath.row == OtherSection.bottomRow.rawValue {

            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileBottomCell") as! ProfileBottomCell
            cell.buttonDelete.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableCell") as! ProfileTableCell
        cell.iconLang.isHidden = true
        cell.switchControl.isHidden = true
        cell.iconArrow.isHidden = false
        
        if indexPath.section == ProfileSection.general.rawValue {
            cell.labelTitle.text = generalNames[indexPath.row]
            
            if indexPath.row == GeneralSection.language.rawValue {
                cell.iconLang.isHidden = false
            }
        }
        else if indexPath.section == ProfileSection.security.rawValue {
            cell.labelTitle.text = securityNames[indexPath.row]
            
            if indexPath.row == SecuritySection.touchID.rawValue {
                cell.switchControl.isHidden = false
                cell.iconArrow.isHidden = true
                cell.switchControl.isOn = DataManager.isUseTouchID()
            }
        }
        else if indexPath.section == ProfileSection.other.rawValue {
            cell.labelTitle.text = otherNames[indexPath.row]
        }
        return cell
    }
}
