//
//  TTAttributed+Utils.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 23.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import TTTAttributedLabel

public extension TTTAttributedLabel {
    
    func addLinks(from title: NSAttributedString) {
        
        title.enumerateAttributes(in: NSMakeRange(0, title.length),
                                  options: .longestEffectiveRangeNotRequired) { (attributes, range, _) in

             if let subAttribute = attributes.first(where: { $0.key == NSAttributedString.Key.link }) {
                                     
                 if let url = subAttribute.value as? URL {
                     self.addLink(to: url, with: range)
                 } else if let string = subAttribute.value as? String,
                     let url = URL(string: string) {
                     self.addLink(to: url, with: range)
                 }
             }
         }
    }
}

