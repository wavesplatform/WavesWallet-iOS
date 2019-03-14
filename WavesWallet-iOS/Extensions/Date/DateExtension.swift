import Foundation

extension Date {
    var normalizeMillisecondsSince1970: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000.0) - GlobalConstants.Utils.timestampServerDiff
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init(timestampNormalize from: Decoder) {
        if let container = try? from.singleValueContainer(),
            let miliseconds = try? container.decode(Int64.self) {
            self = Date(milliseconds: miliseconds + GlobalConstants.Utils.timestampServerDiff)
        }
        else {
            self = Date()
        }
    }
    
    init(isoNormalize from: Decoder) {
        
        let formatter = DateFormatter.iso()

        if let container = try? from.singleValueContainer(),
            let stringDate = try? container.decode(String.self),
            let date = formatter.date(from: stringDate) {
            self = date.addingTimeInterval(TimeInterval(GlobalConstants.Utils.timestampServerDiff) / 1000)
        }
        else {
            self = Date()
        }
    }
    
    var normalize: Date {
        
        //TODO: надо решить как будем придерживаться вывода коректного времени от сервера, учитывая разницу с серверным временем.
        // DexOrderBookRepositoryRemote, LastTradesRepositoryRemote, AssetsRepositoryRemote я конвертнул в DTO модель коректную дату
        // В истории везде в моделях DTO используеться timestamp, там кучу моделей, я манипуляции не делал, в UI вывел .normalize

        return addingTimeInterval(TimeInterval(GlobalConstants.Utils.timestampServerDiff) / 1000)
    }
}
