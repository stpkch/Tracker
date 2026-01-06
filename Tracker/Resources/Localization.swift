import Foundation

enum L10n {
    static func days(_ count: Int) -> String {
        let key: String

        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        if lang != "ru" {
            key = (count == 1) ? "days.one" : "days.other"
        } else {

            let mod10 = count % 10
            let mod100 = count % 100

            if mod10 == 1 && mod100 != 11 {
                key = "days.one"
            } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
                key = "days.few"
            } else if mod10 == 0 || (5...9).contains(mod10) || (11...14).contains(mod100) {
                key = "days.many"
            } else {
                key = "days.other"
            }
        }

        let format = NSLocalizedString(key, comment: "Days count")
        return String(format: format, count)
    }
}
