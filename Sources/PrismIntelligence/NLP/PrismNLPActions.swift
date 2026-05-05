//
//  PrismNLPActions.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

#if canImport(NaturalLanguage)
    import NaturalLanguage

    /// The sentiment of a piece of text.
    public enum PrismSentiment: String, Sendable, CaseIterable {
        /// Positive sentiment.
        case positive
        /// Negative sentiment.
        case negative
        /// Neutral sentiment.
        case neutral
        /// Mixed sentiment.
        case mixed
    }

    /// The type of a named entity.
    public enum PrismEntityType: String, Sendable, CaseIterable {
        /// A person name.
        case person
        /// A place or location.
        case place
        /// An organization name.
        case organization
        /// A date or time expression.
        case date
    }

    /// A named entity extracted from text.
    public struct PrismNLPEntity: Sendable, Equatable {
        /// The entity text.
        public let text: String
        /// The entity type.
        public let type: PrismEntityType
        /// The range of the entity within the original string.
        public let range: Range<String.Index>

        /// Creates a named entity.
        public init(text: String, type: PrismEntityType, range: Range<String.Index>) {
            self.text = text
            self.type = type
            self.range = range
        }
    }

    /// Static methods for common NLP tasks using the NaturalLanguage framework.
    public struct PrismNLPActions: Sendable {
        /// Creates an NLP actions instance.
        public init() {}

        /// Analyzes the sentiment of the given text.
        public static func analyzeSentiment(_ text: String) -> PrismSentiment {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text
            let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
            guard let sentimentValue = sentiment?.rawValue, let score = Double(sentimentValue) else {
                return .neutral
            }
            if score > 0.1 { return .positive }
            if score < -0.1 { return .negative }
            return .neutral
        }

        /// Extracts named entities from the given text.
        public static func extractEntities(_ text: String) -> [PrismNLPEntity] {
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = text
            var entities: [PrismNLPEntity] = []
            let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options)
            { tag, range in
                guard let tag else { return true }
                let entityType: PrismEntityType?
                switch tag {
                case .personalName: entityType = .person
                case .placeName: entityType = .place
                case .organizationName: entityType = .organization
                default: entityType = nil
                }
                if let entityType {
                    entities.append(PrismNLPEntity(text: String(text[range]), type: entityType, range: range))
                }
                return true
            }
            return entities
        }

        /// Detects the dominant language of the given text.
        public static func detectLanguage(_ text: String) -> String? {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            return recognizer.dominantLanguage?.rawValue
        }

        /// Tokenizes text into individual word tokens.
        public static func tokenize(_ text: String) -> [String] {
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            return tokenizer.tokens(for: text.startIndex..<text.endIndex).map { String(text[$0]) }
        }
    }

#endif
