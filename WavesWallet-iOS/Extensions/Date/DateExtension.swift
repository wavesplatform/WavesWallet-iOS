import Foundation

extension Date {
    func millisecondsSince1970(timestampDiff: Int64) -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000.0) - timestampDiff
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init(timestampDecoder from: Decoder, timestampDiff: Int64) {
        if let container = try? from.singleValueContainer(),
            let miliseconds = try? container.decode(Int64.self) {
            self = Date(milliseconds: miliseconds + timestampDiff)
        }
        else {
            self = Date()
        }
    }
    
    init(isoDecoder from: Decoder, timestampDiff: Int64) {
        
        let formatter = DateFormatter.iso()

        if let container = try? from.singleValueContainer(),
            let stringDate = try? container.decode(String.self),
            let date = formatter.date(from: stringDate) {
            self = date.addingTimeInterval(TimeInterval(timestampDiff) / 1000)
        }
        else {
            self = Date()
        }
    }
}
