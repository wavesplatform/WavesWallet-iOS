//
//  DebugView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class DebugView: UIView, NibOwnerLoadable {
    
    @IBOutlet private(set) var chainIdLabel: UILabel!
    
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                 action: #selector(handlerTapGesture(recognizer:)))
    
    var didTapOnView: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setup()
    }
    
    func setup() {
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(tapGesture)
        self.backgroundColor = .submit400
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cornerRadius = Float(self.frame.width * 0.5)
    }
    
    @objc func handlerTapGesture(recognizer: UITapGestureRecognizer) {
        didTapOnView?()
    }
}

extension DebugView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
