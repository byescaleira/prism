//
//  PrismMock.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

/// A protocol for generating test data (mocks).
public protocol PrismMock {
    /// A single mock instance for previews and testing.
    static var mock: Self { get }
    /// An array of mock instances for previews and testing.
    static var mocks: [Self] { get }
}

extension PrismMock {
    /// Returns an array of 10 mock instances by default.
    public static var mocks: [Self] {
        (1...10).map { _ in
            mock
        }
    }
}
