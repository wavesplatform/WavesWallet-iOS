import Foundation

//public class DateUtil {
//    
//    static let dateFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        f.timeStyle = .none
//        f.locale = Locale(identifier: "en_US")
//        return f
//    }()
//    
//    static let timeFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .none
//        f.timeStyle = .short
//        f.locale = Locale(identifier: "en_US")
//        return f
//    }()
//    
//    static let fullFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .long
//        f.timeStyle = .short
//        f.locale = Locale(identifier: "en_US")
//        return f
//    }()
//    
//    class func formatTime(ts: Int64) -> String {
//         return timeFormatter.string(from: Date(milliseconds: ts))
//    }
//    
//    class func formatFull(ts: Int64) -> String {
//        return fullFormatter.string(from: Date(milliseconds: ts))
//    }
//    
//    class func formatStartOfDay(_ ts: Int64) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .none
//        dateFormatter.locale = Locale(identifier: "en_US")
//        return dateFormatter.string(from: Date(milliseconds: ts))
//    }
//    
//}
