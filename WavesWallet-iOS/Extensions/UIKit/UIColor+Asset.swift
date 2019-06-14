//
//  UIColor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    
    static let colorList: [String] = [
        "#39a12c",
        "#6a737b",
        "#e49616",
        "#008ca7",
        "#ff5b38",
        "#ff6a00",
        "#c74124",
        "#00a78e",
        "#b01e53",
        "#e0c61b",
        "#5a81ea",
        "#72b7d2",
        "#a5b5c3",
        "#81c926",
        "#86a3bd",
        "#c1d82f",
        "#5c84a8",
        "#267e1b",
        "#fbb034",
        "#ff846a",
        "#47c1ff",
        "#00a0af",
        "#85d7c6",
        "#8a7967",
        "#26c1c9",
        "#72d28b",
        "#5B1909",
        "#264764",
        "#270774",
        "#8763DE",
        "#F04085",
        "#1E6AFD",
        "#FF1E43",
        "#D3002D",
        "#967400",
        "#264163"
    ]
}

extension UIColor {
    
    static func colorAsset(assetId: String) -> UIColor {
        
        let sum = assetId.unicodeScalars.map { $0.value }.reduce(into: 0) { (result, code) in result = result + code }
        
        let color = Constants.colorList[Int(sum) % Constants.colorList.count]
        return .init(hex: color)
    }
}
