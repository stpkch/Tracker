import UIKit
import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    static func from(date: Date, calendar: Calendar = .current) -> Weekday {
        let number = calendar.component(.weekday, from: date)
        return Weekday(rawValue: number) ?? .monday
    }

    var displayName: String {
        switch self {
        case .monday: return NSLocalizedString("weekday.monday", comment: "")
        case .tuesday: return NSLocalizedString("weekday.tuesday", comment: "")
        case .wednesday: return NSLocalizedString("weekday.wednesday", comment: "")
        case .thursday: return NSLocalizedString("weekday.thursday", comment: "")
        case .friday: return NSLocalizedString("weekday.friday", comment: "")
        case .saturday: return NSLocalizedString("weekday.saturday", comment: "")
        case .sunday: return NSLocalizedString("weekday.sunday", comment: "")
        }
    }
}

enum Plurals {
    static func days(_ count: Int) -> String {
        if count == 0 {
            return NSLocalizedString("days.zero", comment: "")
        }

        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        let key: String

        if lang != "ru" {
            key = (count == 1) ? "days.one" : "days.other"
        } else {
            let mod10 = count % 10
            let mod100 = count % 100

            if mod10 == 1 && mod100 != 11 {
                key = "days.one"
            } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
                key = "days.few"
            } else {
                key = "days.many"
            }
        }

        let format = NSLocalizedString(key, comment: "")
        return String(format: format, count)
    }
}


struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}
