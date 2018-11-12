import Foundation
import UIKit

class MoneyUtil {
    
    class func getScaledText(_ amount: Int64, decimals: Int, scale: Int? = nil) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = decimals
        let result = f.string(from: Decimal(amount) / pow(10, scale ?? decimals) as NSNumber)
        return result ?? ""
    }
    
    class func formatDecimalNoGroupingAndZeros(_ amount: Decimal, decimals: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ""
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 0
        return f.string(from: amount as NSNumber)!
    }
    
    class func formatDecimalTrimZeros(_ amount: Decimal, decimals: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 1
        let result = f.string(from: amount as NSNumber)
        return result ?? ""
    }

    class func getScaledTextTrimZeros(_ amount: Int64, decimals: Int, scale: Int? = nil) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 0
        let result = f.string(from: Decimal(amount) / pow(10, scale ?? decimals) as NSNumber)
        return result ?? ""
    }

    class func getScaledPair(_ amount: Int64, _ decimals: Int) -> (String, String) {
        let s = getScaledText(amount, decimals: decimals)
        let len = s.count
        let dWSep = decimals > 0 ? decimals + 1 : 0
        let s1 = String(s.suffix(dWSep))
        let s2 = String(s.prefix(max(0, len - dWSep)))
        return (s2, s1)
    }

    class func parseUnscaled(_ text: String, _ scale: Int) -> Int64? {
        let s = text.replacingOccurrences(of: groupSeparator(), with: "")

        if let d = Decimal(string: s, locale: Locale.current) {
            return Int64(truncating: d * Decimal(10 ^^ scale) as NSNumber)
        } else {
            return nil
        }
    }

    class func getScaledDecimal(_ value: Int64, _ scale: Int) -> Decimal {
        return Decimal(value) / Decimal(10 ^^ scale)
    }

    class func parseMoney(_ text: String, _ scale: Int) -> Money? {
        if let u = parseUnscaled(text, scale) {
            return Money(u, scale)
        } else {
            return nil
        }
    }

    class func parseDecimal(_ text: String) -> Decimal? {
        let s = text.replacingOccurrences(of: groupSeparator(), with: "")
        return Decimal(string: s, locale: Locale.current)
    }

    class func parseDecimalPoint(_ text: String) -> Decimal? {
        let s = text.replacingOccurrences(of: " ", with: "")
        return Decimal(string: s, locale: Locale(identifier: "en_US"))
    }

    class func getDecimalPoint(_ point: Double) -> Decimal? {
        let decimal = NSDecimalNumber(value: point)
        return decimal.decimalValue
    }

    class func formatDecimals(_ amount: Decimal, decimals: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = 1
        f.roundingMode = .down
        return f.string(from: amount as NSNumber) ?? ""
    }

    class func decimalSeparator() -> String {
        return Locale.current.decimalSeparator ?? "."
    }

    class func groupSeparator() -> String {
        return Locale.current.groupingSeparator ?? ","
    }

    static let kAmountLength = 20

    class func shouldChangeAmount(_ textField: UITextField, _ decimals: Int, _ range: NSRange, _ string: String) -> Bool {
        guard let nsString = textField.text as NSString? else { return true }
        let newString = nsString.replacingCharacters(in: range, with: string)
        guard !newString.isEmpty else { return true }

        if newString.count <= kAmountLength {
            if let d = parseDecimal(newString) {
                return d >= 0 && -d.exponent <= decimals
            }
        }
        return false
    }
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^: PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int64 {
    return Int64(pow(Double(radix), Double(power)))
}

