import SwiftUI

extension PrismStrings {
    static var continueAction: LocalizedStringKey { "prism.continue" }
    static var getStarted: LocalizedStringKey { "prism.getStarted" }
    static var paste: LocalizedStringKey { "prism.paste" }
    static var save: LocalizedStringKey { "prism.save" }
    static var done: LocalizedStringKey { "prism.done" }
    static var edit: LocalizedStringKey { "prism.edit" }
    static var add: LocalizedStringKey { "prism.add" }
    static var close: LocalizedStringKey { "prism.close" }
    static var back: LocalizedStringKey { "prism.back" }
    static var next: LocalizedStringKey { "prism.next" }
    static var previous: LocalizedStringKey { "prism.previous" }
    static var share: LocalizedStringKey { "prism.share" }
    static var settings: LocalizedStringKey { "prism.settings" }
    static var selectPhoto: LocalizedStringKey { "prism.selectPhoto" }
    static var untitled: LocalizedStringKey { "prism.untitled" }
    static var noResults: LocalizedStringKey { "prism.noResults" }
    static var tryAgain: LocalizedStringKey { "prism.tryAgain" }
    static var errorOccurred: LocalizedStringKey { "prism.errorOccurred" }
}

extension String {
    static var prismContinue: String { String(localized: "prism.continue", defaultValue: "Continue", bundle: .module) }
    static var prismGetStarted: String {
        String(localized: "prism.getStarted", defaultValue: "Get Started", bundle: .module)
    }
    static var prismPaste: String { String(localized: "prism.paste", defaultValue: "Paste", bundle: .module) }
    static var prismSave: String { String(localized: "prism.save", defaultValue: "Save", bundle: .module) }
    static var prismDone: String { String(localized: "prism.done", defaultValue: "Done", bundle: .module) }
    static var prismEdit: String { String(localized: "prism.edit", defaultValue: "Edit", bundle: .module) }
    static var prismAdd: String { String(localized: "prism.add", defaultValue: "Add", bundle: .module) }
    static var prismClose: String { String(localized: "prism.close", defaultValue: "Close", bundle: .module) }
    static var prismBack: String { String(localized: "prism.back", defaultValue: "Back", bundle: .module) }
    static var prismNext: String { String(localized: "prism.next", defaultValue: "Next", bundle: .module) }
    static var prismPrevious: String { String(localized: "prism.previous", defaultValue: "Previous", bundle: .module) }
    static var prismShare: String { String(localized: "prism.share", defaultValue: "Share", bundle: .module) }
    static var prismSettings: String { String(localized: "prism.settings", defaultValue: "Settings", bundle: .module) }
    static var prismSelectPhoto: String {
        String(localized: "prism.selectPhoto", defaultValue: "Select Photo", bundle: .module)
    }
    static var prismUntitled: String { String(localized: "prism.untitled", defaultValue: "Untitled", bundle: .module) }
    static var prismNoResults: String {
        String(localized: "prism.noResults", defaultValue: "No Results", bundle: .module)
    }
    static var prismTryAgain: String { String(localized: "prism.tryAgain", defaultValue: "Try Again", bundle: .module) }
    static var prismErrorOccurred: String {
        String(localized: "prism.errorOccurred", defaultValue: "An error occurred", bundle: .module)
    }
}
