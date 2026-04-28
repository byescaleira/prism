import SwiftUI

/// A chainable builder for constructing styled AttributedString values using PrismUI tokens.
public struct PrismAttributedStringBuilder: Sendable {
    private var segments: [AttributedString]

    /// Creates an empty attributed string builder.
    public init() {
        self.segments = []
    }

    /// Appends plain text.
    public func text(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        copy.segments.append(AttributedString(string))
        return copy
    }

    /// Appends bold text.
    public func bold(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.font = .body.bold()
        copy.segments.append(attr)
        return copy
    }

    /// Appends italic text.
    public func italic(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.font = .body.italic()
        copy.segments.append(attr)
        return copy
    }

    /// Appends monospaced code text.
    public func code(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.font = .system(.body, design: .monospaced)
        copy.segments.append(attr)
        return copy
    }

    /// Appends a hyperlink with display text.
    public func link(_ string: String, url: URL) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.link = url
        attr.underlineStyle = .single
        copy.segments.append(attr)
        return copy
    }

    /// Appends colored text.
    public func colored(_ string: String, color: Color) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.foregroundColor = color
        copy.segments.append(attr)
        return copy
    }

    /// Appends a newline character.
    public func newline() -> PrismAttributedStringBuilder {
        var copy = self
        copy.segments.append(AttributedString("\n"))
        return copy
    }

    /// Produces the final attributed string from all appended segments.
    public func build() -> AttributedString {
        var result = AttributedString()
        for segment in segments {
            result.append(segment)
        }
        return result
    }
}

// MARK: - Result Builder

/// A result builder that composes AttributedString values declaratively.
@resultBuilder
public struct PrismTextBuilder {
    /// Builds a single attributed string from a component.
    public static func buildBlock(_ components: AttributedString...) -> AttributedString {
        var result = AttributedString()
        for component in components {
            result.append(component)
        }
        return result
    }

    /// Supports optional attributed string components.
    public static func buildOptional(_ component: AttributedString?) -> AttributedString {
        component ?? AttributedString()
    }

    /// Builds the first branch of an if-else.
    public static func buildEither(first component: AttributedString) -> AttributedString {
        component
    }

    /// Builds the second branch of an if-else.
    public static func buildEither(second component: AttributedString) -> AttributedString {
        component
    }

    /// Builds an array of attributed strings from a loop.
    public static func buildArray(_ components: [AttributedString]) -> AttributedString {
        var result = AttributedString()
        for component in components {
            result.append(component)
        }
        return result
    }
}

// MARK: - Convenience Extensions

extension AttributedString {
    /// Creates a bold attributed string.
    public static func prismBold(_ string: String) -> AttributedString {
        var attr = AttributedString(string)
        attr.font = .body.bold()
        return attr
    }

    /// Creates an italic attributed string.
    public static func prismItalic(_ string: String) -> AttributedString {
        var attr = AttributedString(string)
        attr.font = .body.italic()
        return attr
    }

    /// Creates a monospaced code attributed string.
    public static func prismCode(_ string: String) -> AttributedString {
        var attr = AttributedString(string)
        attr.font = .system(.body, design: .monospaced)
        return attr
    }

    /// Creates a linked attributed string.
    public static func prismLink(_ string: String, url: URL) -> AttributedString {
        var attr = AttributedString(string)
        attr.link = url
        attr.underlineStyle = .single
        return attr
    }
}
