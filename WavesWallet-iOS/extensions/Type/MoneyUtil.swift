import Foundation
import UIKit

class MoneyUtil {
    
    class func getScaledFullText(_ amount: Int64, decimals: Int, isFiat: Bool) -> String {
        let f = NumberFormatter()
        f.locale = GlobalConstants.moneyLocale
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = isFiat ? decimals : 0
        let result = f.string(from: Decimal(amount) / pow(10, decimals) as NSNumber)
        return result ?? ""
    }

    class func getScaledText(_ amount: Int64, decimals: Int) -> String {
        let f = NumberFormatter()
        f.locale = GlobalConstants.moneyLocale
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
            return getScaledText(amount, decimals: decimals)
        }
        
        let exp = Int(log10(num) / 3)
        
        let units = ["K", "M", "B", "T", "P", "E"]
        let roundedNum = floor(10 * num / pow(1000, Double(exp))) / 10
        
        let floatingValue = modf(roundedNum).1
        if floatingValue == 0 {
            return String(Int(roundedNum)) + units[exp-1]
        }

        return "\(roundedNum)\(units[exp-1])"
    }
}
