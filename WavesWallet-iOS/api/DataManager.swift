//
//  DataManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 20.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class DataManager: NSObject {

    var orderBooks: NSArray! = nil
    var verifiedAssets: NSDictionary! = nil
    
    static let shared = DataManager()
    
    class func getCandleTimeFrame() -> Int {
        
        let timeFrame = UserDefaults.standard.integer(forKey: "candleTimeFrame")
        
        if timeFrame > 0 {
            return timeFrame
        }
        
        return 15
    }
    
    class func setCandleTimeFrame(_ timeFrame : Int) {
        UserDefaults.standard.set(timeFrame, forKey: "candleTimeFrame")
        UserDefaults.standard.synchronize()
    }
    
    class func isShowBarChart() -> Bool {
        return UserDefaults.standard.bool(forKey: "isShowBarChart")
    }
    
    class func setShowBarChart(isShow: Bool) {
        UserDefaults.standard.set(isShow, forKey: "isShowBarChart")
        UserDefaults.standard.synchronize()
    }
    
}
