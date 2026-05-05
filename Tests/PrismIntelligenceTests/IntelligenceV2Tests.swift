//
//  IntelligenceV2Tests.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Testing

@testable import PrismIntelligence

// MARK: - Embedding Store Tests

@Suite("PrismEmbedding")
struct PrismEmbeddingTests {
    @Test("Embedding stores vector and metadata")
    func embeddingStoresVectorAndMetadata() {
        let embedding = PrismEmbedding(
            id: "e1",
            vector: [1.0, 2.0, 3.0],
            metadata: ["source": "test"]
        )
        #expect(embedding.id == "e1")
        #expect(embedding.vector == [1.0, 2.0, 3.0])
        #expect(embedding.metadata["source"] == "test")
    }

    @Test("Embedding store add and count")
    func embeddingStoreAddAndCount() async {
        let store = PrismEmbeddingStore()
        await store.add(PrismEmbedding(id: "a", vector: [1.0], metadata: [:]))
        await store.add(PrismEmbedding(id: "b", vector: [2.0], metadata: [:]))
        let count = await store.count
        #expect(count == 2)
    }

    @Test("Embedding store search returns results sorted by similarity")
    func embeddingStoreSearchSortedBySimilarity() async {
        let store = PrismEmbeddingStore()
        await store.add(PrismEmbedding(id: "far", vector: [0.0, 1.0, 0.0], metadata: [:]))
        await store.add(PrismEmbedding(id: "close", vector: [1.0, 0.0, 0.0], metadata: [:]))
        await store.add(PrismEmbedding(id: "mid", vector: [0.5, 0.5, 0.0], metadata: [:]))

        let results = await store.search(query: [1.0, 0.0, 0.0], topK: 3)
        #expect(results.count == 3)
        #expect(results[0].embedding.id == "close")
        #expect(results[0].similarity > results[1].similarity)
        #expect(results[1].similarity > results[2].similarity)
    }

    @Test("Cosine similarity calculation")
    func cosineSimilarityCalculation() {
        let identical = PrismEmbeddingStore.cosineSimilarity([1.0, 0.0], [1.0, 0.0])
        #expect(abs(identical - 1.0) < 0.001)

        let orthogonal = PrismEmbeddingStore.cosineSimilarity([1.0, 0.0], [0.0, 1.0])
        #expect(abs(orthogonal) < 0.001)

        let opposite = PrismEmbeddingStore.cosineSimilarity([1.0, 0.0], [-1.0, 0.0])
        #expect(abs(opposite - (-1.0)) < 0.001)

        let empty = PrismEmbeddingStore.cosineSimilarity([], [])
        #expect(empty == 0)
    }

    @Test("Embedding store clear removes all embeddings")
    func embeddingStoreClear() async {
        let store = PrismEmbeddingStore()
        await store.add(PrismEmbedding(id: "a", vector: [1.0], metadata: [:]))
        await store.clear()
        let count = await store.count
        #expect(count == 0)
    }
}

// MARK: - Text Chunker Tests

@Suite("PrismTextChunker")
struct PrismTextChunkerTests {
    @Test("Text chunker splits text correctly")
    func textChunkerSplitsCorrectly() {
        let chunker = PrismTextChunker()
        let text = "abcdefghij"
        let chunks = chunker.chunk(text, size: 4, overlap: 0)
        #expect(chunks == ["abcd", "efgh", "ij"])
    }

    @Test("Text chunker overlap")
    func textChunkerOverlap() {
        let chunker = PrismTextChunker()
        let text = "abcdefghij"
        let chunks = chunker.chunk(text, size: 5, overlap: 2)
        #expect(chunks.count >= 2)
        #expect(chunks[0] == "abcde")
        #expect(chunks[1] == "defgh")
    }

    @Test("Text chunker empty input returns empty")
    func textChunkerEmptyInput() {
        let chunker = PrismTextChunker()
        let chunks = chunker.chunk("", size: 5, overlap: 2)
        #expect(chunks.isEmpty)
    }
}

// MARK: - RAG Config Tests

@Suite("PrismRAGConfig")
struct PrismRAGConfigTests {
    @Test("RAG config stores values")
    func ragConfigStoresValues() {
        let config = PrismRAGConfig(chunkSize: 100, overlapSize: 20, topK: 5)
        #expect(config.chunkSize == 100)
        #expect(config.overlapSize == 20)
        #expect(config.topK == 5)
    }

    @Test("RAG config defaults")
    func ragConfigDefaults() {
        let config = PrismRAGConfig()
        #expect(config.chunkSize == 500)
        #expect(config.overlapSize == 50)
        #expect(config.topK == 3)
    }
}

// MARK: - Vision Classification Tests

#if canImport(Vision)

    @Suite("PrismVisionClassifier")
    struct PrismVisionClassifierTests {
        @Test("Classification result stores label and confidence")
        func classificationResultStoresLabelAndConfidence() {
            let result = PrismClassificationResult(label: "cat", confidence: 0.95)
            #expect(result.label == "cat")
            #expect(result.confidence == 0.95)
        }

        @Test("Classification results are equatable")
        func classificationResultsAreEquatable() {
            let a = PrismClassificationResult(label: "cat", confidence: 0.95)
            let b = PrismClassificationResult(label: "cat", confidence: 0.95)
            #expect(a == b)
        }
    }

#endif

// MARK: - NLP Tests

#if canImport(NaturalLanguage)

    @Suite("PrismNLPActions")
    struct PrismNLPActionsTests {
        @Test("Sentiment has 4 cases")
        func sentimentHas4Cases() {
            #expect(PrismSentiment.allCases.count == 4)
            #expect(PrismSentiment.allCases.contains(.positive))
            #expect(PrismSentiment.allCases.contains(.negative))
            #expect(PrismSentiment.allCases.contains(.neutral))
            #expect(PrismSentiment.allCases.contains(.mixed))
        }

        @Test("Entity type has 4 cases")
        func entityTypeHas4Cases() {
            #expect(PrismEntityType.allCases.count == 4)
            #expect(PrismEntityType.allCases.contains(.person))
            #expect(PrismEntityType.allCases.contains(.place))
            #expect(PrismEntityType.allCases.contains(.organization))
            #expect(PrismEntityType.allCases.contains(.date))
        }

        @Test("NLP actions tokenize")
        func nlpActionsTokenize() {
            let tokens = PrismNLPActions.tokenize("Hello world from Swift")
            #expect(tokens.count == 4)
            #expect(tokens.contains("Hello"))
            #expect(tokens.contains("world"))
        }

        @Test("NLP actions detect language")
        func nlpActionsDetectLanguage() {
            let lang = PrismNLPActions.detectLanguage("This is a test sentence in English")
            #expect(lang == "en")
        }
    }

#endif

// MARK: - Structured Output Tests

@Suite("PrismStructuredOutput")
struct PrismStructuredOutputTests {
    @Test("Extract JSON from mixed text")
    func extractJSONFromMixedText() {
        let parser = PrismStructuredParser()
        let text = "Here is some text {\"name\": \"Prism\", \"version\": 2} and more text"
        let json = parser.extractJSON(text)
        #expect(json == "{\"name\": \"Prism\", \"version\": 2}")
    }

    @Test("Extract JSON returns nil for no JSON")
    func extractJSONReturnsNilForNoJSON() {
        let parser = PrismStructuredParser()
        let text = "Just plain text with no JSON"
        let json = parser.extractJSON(text)
        #expect(json == nil)
    }

    @Test("Extract key values from text")
    func extractKeyValuesFromText() {
        let parser = PrismStructuredParser()
        let text = """
            Name: Prism
            Version: 2.7.0
            Language: Swift
            """
        let kv = parser.extractKeyValues(text)
        #expect(kv["Name"] == "Prism")
        #expect(kv["Version"] == "2.7.0")
        #expect(kv["Language"] == "Swift")
    }

    @Test("Parse Decodable from JSON text")
    func parseDecodableFromJSONText() {
        struct Info: Decodable {
            let name: String
            let count: Int
        }
        let parser = PrismStructuredParser()
        let text = "Result: {\"name\": \"test\", \"count\": 42}"
        let info = parser.parse(text, as: Info.self)
        #expect(info?.name == "test")
        #expect(info?.count == 42)
    }

    @Test("Output validator validates JSON schema")
    func outputValidatorValidatesJSON() {
        let validator = PrismOutputValidator()
        #expect(validator.validate("{\"key\": \"value\"}", against: .json(String.self)))
        #expect(!validator.validate("no json here", against: .json(String.self)))
    }
}

// MARK: - Model Manager Tests

@Suite("PrismModelManager")
struct PrismModelManagerTests {
    @Test("Model info stores properties")
    func modelInfoStoresProperties() {
        let info = PrismModelInfo(id: "m1", name: "Classifier", type: .classifier, size: 1024, isLoaded: true)
        #expect(info.id == "m1")
        #expect(info.name == "Classifier")
        #expect(info.type == .classifier)
        #expect(info.size == 1024)
        #expect(info.isLoaded == true)
    }

    @Test("Model type has 5 cases")
    func modelTypeHas5Cases() {
        #expect(PrismModelType.allCases.count == 5)
        #expect(PrismModelType.allCases.contains(.classifier))
        #expect(PrismModelType.allCases.contains(.regressor))
        #expect(PrismModelType.allCases.contains(.nlp))
        #expect(PrismModelType.allCases.contains(.embedding))
        #expect(PrismModelType.allCases.contains(.custom))
    }

    @Test("Model manager register and list")
    func modelManagerRegisterAndList() async {
        let manager = PrismModelManager()
        await manager.register(PrismModelInfo(id: "m1", name: "Model 1", type: .classifier))
        await manager.register(PrismModelInfo(id: "m2", name: "Model 2", type: .regressor))
        let models = await manager.loadedModels
        #expect(models.count == 2)
    }

    @Test("Model manager unload sets isLoaded to false")
    func modelManagerUnload() async {
        let manager = PrismModelManager()
        await manager.register(PrismModelInfo(id: "m1", name: "Model", type: .nlp, isLoaded: true))
        await manager.unload(id: "m1")
        let model = await manager.model(for: "m1")
        #expect(model?.isLoaded == false)
    }

    @Test("Model manager swap hot-swaps models")
    func modelManagerSwap() async {
        let manager = PrismModelManager()
        await manager.register(PrismModelInfo(id: "old", name: "Old", type: .embedding, isLoaded: true))
        await manager.register(PrismModelInfo(id: "new", name: "New", type: .embedding, isLoaded: false))
        await manager.swap(from: "old", to: "new")
        let old = await manager.model(for: "old")
        let new = await manager.model(for: "new")
        #expect(old?.isLoaded == false)
        #expect(new?.isLoaded == true)
    }
}
