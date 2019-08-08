//
//  SearchBarView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

protocol SearchBarViewDelegate: AnyObject {
    
    func searchBarDidChangeText(_ searchText: String)
}

final class SearchBarView: UIView, NibOwnerLoadable {

    @IBOutlet private(set) weak var textField: UITextField!
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!

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

        textField.attributedPlaceholder = NSAttributedString(string: Localizable.Waves.Dexmarket.Searchbar.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.basic500])
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    func startLoading() {
        iconImageView.isHidden = true
        indicatorView.startAnimating()
    }
    
    func stopLoading() {
        iconImageView.isHidden = false
        indicatorView.stopAnimating()
    }
    
}

//MARK: UITextFieldDelegate
extension SearchBarView: UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        iconImageView.image = Images.search24Black.image
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        iconImageView.image = Images.search24Basic500.image
    }
    
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
