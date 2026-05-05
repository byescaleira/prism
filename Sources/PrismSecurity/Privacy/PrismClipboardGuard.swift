#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

import Foundation

/// Automatically clears the clipboard after a timeout when sensitive data is copied.
///
/// ```swift
/// let guard = PrismClipboardGuard(clearAfter: 30)
/// guard.copySecurely("my-secret-token")
/// // Clipboard auto-clears after 30 seconds
/// ```
public final class PrismClipboardGuard: @unchecked Sendable {
    private let clearAfter: TimeInterval
    private let lock = NSLock()
    private var clearTask: Task<Void, Never>?

    /// Creates a clipboard guard.
    /// - Parameter clearAfter: Seconds before clipboard auto-clears. Defaults to 30.
    public init(clearAfter: TimeInterval = 30) {
        self.clearAfter = clearAfter
    }

    deinit {
        lock.withLock { clearTask?.cancel() }
    }

    /// Copies a string to the clipboard and schedules auto-clear.
    public func copySecurely(_ string: String) {
        #if canImport(UIKit) && !os(watchOS)
            UIPasteboard.general.string = string
        #elseif canImport(AppKit)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(string, forType: .string)
        #endif
        scheduleClear()
    }

    /// Copies data to the clipboard and schedules auto-clear.
    public func copySecurely(_ data: Data) {
        #if canImport(UIKit) && !os(watchOS)
            UIPasteboard.general.setData(data, forPasteboardType: "public.data")
        #endif
        scheduleClear()
    }

    /// Clears the clipboard immediately.
    public func clearNow() {
        lock.withLock { clearTask?.cancel() }
        #if canImport(UIKit) && !os(watchOS)
            UIPasteboard.general.items = []
        #elseif canImport(AppKit)
            NSPasteboard.general.clearContents()
        #endif
    }

    /// Cancels any pending auto-clear.
    public func cancelClear() {
        lock.withLock { clearTask?.cancel() }
    }

    private func scheduleClear() {
        lock.withLock { clearTask?.cancel() }

        let delay = clearAfter
        let task = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            self?.clearNow()
        }

        lock.withLock { clearTask = task }
    }
}
