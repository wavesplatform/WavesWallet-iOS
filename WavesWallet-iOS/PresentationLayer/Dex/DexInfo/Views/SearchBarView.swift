//
//  SearchBarView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol SearchBarViewDelegate: AnyObject {
    
    func searchBarDidChangeText(_ searchText: String)
}

final class SearchBarView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var textField: UITextField!

    weak var delegate: SearchBarViewDelegate?
    
    var searchText: String {
        if let text = textField.text {
            return text
        }
        return ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textField.attributedPlaceholder = NSAttributedString(string: Localizable.Waves.Dexmarket.Searchbar.placeholder, attributes: [NSAttributedStringKey.foregroundColor : UIColor.basic500])
    }
    
}

//MARK: UITextFieldDelegate
extension SearchBarView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Actions

private extension SearchBarView {
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if let text = textField.text {
            delegate?.searchBarDidChangeText(text)
        }
    }
}
