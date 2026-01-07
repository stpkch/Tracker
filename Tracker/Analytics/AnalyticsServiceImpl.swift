import Foundation
import AppMetricaCore

final class AnalyticsService: AnalyticsReporting {

    static let shared = AnalyticsService()

    private init() {}

    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        var params: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]

        if let item {
            params["item"] = item.rawValue
        }

        print("ANALYTICS:", params)

        AppMetrica.reportEvent(name: "ui_event", parameters: params, onFailure: { error in
            print("APPMETRICA REPORT ERROR:", error.localizedDescription)
        })
    }
}
