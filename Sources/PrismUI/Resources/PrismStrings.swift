import SwiftUI

enum PrismStrings {
    static var dismiss: LocalizedStringKey { "prism.dismiss" }
    static var cancel: LocalizedStringKey { "prism.cancel" }
    static var retry: LocalizedStringKey { "prism.retry" }
    static var search: LocalizedStringKey { "prism.search" }
    static var delete: LocalizedStringKey { "prism.delete" }
    static var archive: LocalizedStringKey { "prism.archive" }
    static var pin: LocalizedStringKey { "prism.pin" }
    static var flag: LocalizedStringKey { "prism.flag" }
    static var remove: LocalizedStringKey { "prism.remove" }
    static var loading: LocalizedStringKey { "prism.loading" }
    static var inProgress: LocalizedStringKey { "prism.inProgress" }
    static var running: LocalizedStringKey { "prism.running" }
    static var complete: LocalizedStringKey { "prism.complete" }
    static var paused: LocalizedStringKey { "prism.paused" }
    static var empty: LocalizedStringKey { "prism.empty" }
    static var customColor: LocalizedStringKey { "prism.customColor" }
    static var colorSwatch: LocalizedStringKey { "prism.colorSwatch" }
    static var avatar: LocalizedStringKey { "prism.avatar" }
    static var online: LocalizedStringKey { "prism.status.online" }
    static var offline: LocalizedStringKey { "prism.status.offline" }
    static var busy: LocalizedStringKey { "prism.status.busy" }
    static var away: LocalizedStringKey { "prism.status.away" }
    static var progress: LocalizedStringKey { "prism.progress" }
    static var pinEntry: LocalizedStringKey { "prism.pinEntry" }
    static var rating: LocalizedStringKey { "prism.rating" }
    static var countdownTimer: LocalizedStringKey { "prism.countdownTimer" }
}

extension String {
    static var prismDismiss: String { String(localized: "prism.dismiss", defaultValue: "Dismiss", bundle: .module) }
    static var prismCancel: String { String(localized: "prism.cancel", defaultValue: "Cancel", bundle: .module) }
    static var prismRetry: String { String(localized: "prism.retry", defaultValue: "Retry", bundle: .module) }
    static var prismSearch: String { String(localized: "prism.search", defaultValue: "Search", bundle: .module) }
    static var prismDelete: String { String(localized: "prism.delete", defaultValue: "Delete", bundle: .module) }
    static var prismArchive: String { String(localized: "prism.archive", defaultValue: "Archive", bundle: .module) }
    static var prismPin: String { String(localized: "prism.pin", defaultValue: "Pin", bundle: .module) }
    static var prismFlag: String { String(localized: "prism.flag", defaultValue: "Flag", bundle: .module) }
    static var prismRemove: String { String(localized: "prism.remove", defaultValue: "Remove", bundle: .module) }
    static var prismLoading: String { String(localized: "prism.loading", defaultValue: "Loading", bundle: .module) }
    static var prismInProgress: String { String(localized: "prism.inProgress", defaultValue: "In progress", bundle: .module) }
    static var prismRunning: String { String(localized: "prism.running", defaultValue: "Running", bundle: .module) }
    static var prismComplete: String { String(localized: "prism.complete", defaultValue: "Complete", bundle: .module) }
    static var prismPaused: String { String(localized: "prism.paused", defaultValue: "Paused", bundle: .module) }
    static var prismAvatar: String { String(localized: "prism.avatar", defaultValue: "Avatar", bundle: .module) }
    static var prismOnline: String { String(localized: "prism.status.online", defaultValue: "Online", bundle: .module) }
    static var prismOffline: String { String(localized: "prism.status.offline", defaultValue: "Offline", bundle: .module) }
    static var prismBusy: String { String(localized: "prism.status.busy", defaultValue: "Busy", bundle: .module) }
    static var prismAway: String { String(localized: "prism.status.away", defaultValue: "Away", bundle: .module) }
    static var prismCustomColor: String { String(localized: "prism.customColor", defaultValue: "Custom color", bundle: .module) }
    static var prismColorSwatch: String { String(localized: "prism.colorSwatch", defaultValue: "Color swatch", bundle: .module) }
    static var prismProgress: String { String(localized: "prism.progress", defaultValue: "Progress", bundle: .module) }
    static var prismPinEntry: String { String(localized: "prism.pinEntry", defaultValue: "PIN entry", bundle: .module) }
    static var prismRating: String { String(localized: "prism.rating", defaultValue: "Rating", bundle: .module) }
    static var prismCountdownTimer: String { String(localized: "prism.countdownTimer", defaultValue: "Countdown timer", bundle: .module) }
    static var prismEmpty: String { String(localized: "prism.empty", defaultValue: "Empty", bundle: .module) }
}
