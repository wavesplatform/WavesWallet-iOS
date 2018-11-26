import Foundation
import UIKit

private enum Constansts {
    static let maximumShortDecimals = 3
}

class MoneyUtil {
    
    class func getScaledFullText(_ amount: Int64, decimals: Int, isFiat: Bool) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = isFiat ? decimals : 0
        let result = f.string(from: Decimal(amount) / pow(10, decimals) as NSNumber)
        return result ?? ""
    }

    class func getScaledText(_ amount: Int64, decimals: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 0
        let result = f.string(from: Decimal(amount) / pow(10, decimals) as NSNumber)
        return result ?? ""
    }
    
    class func getScaledShortText(_ amount: Int64, decimals: Int) -> String {

        let decimalValue = Decimal(amount) / pow(10, decimals)
        let num = decimalValue.doubleValue;
        
        if num < 1000 {
            
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = min(Constansts.maximumShortDecimals, decimals)
            f.minimumFractionDigits = 0
            let result = f.string(from: decimalValue as NSNumber)
            return result ?? ""
        }
        
        let exp = Int(log10(num) / 3)
        
        let units = ["K", "M", "G", "T", "P", "E"]
        let roundedNum = round(10 * num / pow(1000, Double(exp))) / 10
        
        return "\(roundedNum)\(units[exp-1])"
    }
}
