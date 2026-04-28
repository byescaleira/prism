//
//  PrismTimeTravel.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Observation

/// A snapshot capturing a single moment in state history.
public struct PrismStateSnapshot<State: PrismState>: Sendable {
    /// The state value at the time of capture.
    public let state: State

    /// A description of the action that produced this state.
    public let action: String

    /// The wall-clock time when the snapshot was recorded.
    public let timestamp: Date

    /// The zero-based position of this snapshot in the timeline.
    public let index: Int

    /// Creates a new state snapshot.
    public init(
        state: State,
        action: String,
        timestamp: Date,
        index: Int
    ) {
        self.state = state
        self.action = action
        self.timestamp = timestamp
        self.index = index
    }
}

/// A time-travel debugger that records state snapshots and allows navigation through history.
@MainActor
@Observable
public final class PrismTimeTravelDebugger<State: PrismState> {
    /// All recorded snapshots ordered by index.
    public private(set) var snapshots: [PrismStateSnapshot<State>] = []

    /// The index of the currently active snapshot, or -1 when empty.
    public private(set) var currentIndex: Int = -1

    /// The maximum number of snapshots to retain before evicting the oldest.
    public let maxSnapshots: Int

    /// Whether there is a previous snapshot to navigate to.
    public var canGoBack: Bool {
        currentIndex > 0
    }

    /// Whether there is a later snapshot to navigate to.
    public var canGoForward: Bool {
        currentIndex < snapshots.count - 1
    }

    /// Creates a debugger with the given snapshot capacity.
    public init(maxSnapshots: Int = 100) {
        self.maxSnapshots = maxSnapshots
    }

    /// Records a new snapshot for the given state and action description.
    public func record(state: State, action: String) {
        // When recording after navigating back, discard future snapshots
        if currentIndex < snapshots.count - 1 {
            snapshots = Array(snapshots.prefix(currentIndex + 1))
        }

        let snapshot = PrismStateSnapshot(
            state: state,
            action: action,
            timestamp: Date(),
            index: snapshots.count
        )

        snapshots.append(snapshot)
        currentIndex = snapshots.count - 1

        // Evict the oldest snapshot when over capacity
        if snapshots.count > maxSnapshots {
            snapshots.removeFirst()
            currentIndex = snapshots.count - 1
        }
    }

    /// Moves one step backward in the timeline, returning the snapshot if possible.
    @discardableResult
    public func goBack() -> PrismStateSnapshot<State>? {
        guard canGoBack else { return nil }
        currentIndex -= 1
        return snapshots[currentIndex]
    }

    /// Moves one step forward in the timeline, returning the snapshot if possible.
    @discardableResult
    public func goForward() -> PrismStateSnapshot<State>? {
        guard canGoForward else { return nil }
        currentIndex += 1
        return snapshots[currentIndex]
    }

    /// Jumps to the snapshot at the given index, returning it if valid.
    @discardableResult
    public func jumpTo(index: Int) -> PrismStateSnapshot<State>? {
        guard index >= 0, index < snapshots.count else { return nil }
        currentIndex = index
        return snapshots[currentIndex]
    }
}
