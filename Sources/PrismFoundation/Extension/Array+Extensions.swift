//
//  Array+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/08/25.
//

import Foundation

extension Array {
    public func asyncMap<T>(
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        var results = [T]()
        for item in self {
            try await results.append(transform(item))
        }
        return results
    }

    public func asyncCompactMap<T>(
        _ transform: @Sendable @escaping (Element) async throws -> T?
    ) async rethrows -> [T] {
        var results = [T]()
        for item in self {
            if let transformed = try await transform(item) {
                results.append(transformed)
            }
        }
        return results
    }

    public func asyncFilter(
        _ predicate: @Sendable @escaping (Element) async throws -> Bool
    ) async rethrows -> [Element] {
        var results = [Element]()
        for item in self {
            if try await predicate(item) {
                results.append(item)
            }
        }
        return results
    }

    public var second: Element? {
        count > 1 ? self[1] : nil
    }

    public var secondToLast: Element? {
        count > 1 ? self[count - 2] : nil
    }

    public func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Sequence {
    public func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T?>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted {
            switch ($0[keyPath: keyPath], $1[keyPath: keyPath]) {
            case (let lhs?, let rhs?):
                return comparator(lhs, rhs)
            case (.some, nil):
                return true
            case (nil, .some), (nil, nil):
                return false
            }
        }
    }
}

extension Array {
    public subscript(safe index: Index) -> Element? {
        index >= .zero && index < count ? self[index] : nil
    }
}
