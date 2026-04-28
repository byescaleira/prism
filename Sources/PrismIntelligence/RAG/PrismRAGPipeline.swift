//
//  PrismRAGPipeline.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// Configuration for the RAG pipeline.
public struct PrismRAGConfig: Sendable {
    /// The number of characters per text chunk.
    public let chunkSize: Int
    /// The number of overlapping characters between consecutive chunks.
    public let overlapSize: Int
    /// The number of top results to retrieve during search.
    public let topK: Int

    /// Creates a RAG configuration.
    public init(chunkSize: Int = 500, overlapSize: Int = 50, topK: Int = 3) {
        self.chunkSize = chunkSize
        self.overlapSize = overlapSize
        self.topK = topK
    }
}

/// Splits text into overlapping chunks for embedding ingestion.
public struct PrismTextChunker: Sendable {
    /// Creates a text chunker.
    public init() {}

    /// Splits text into chunks of the given size with the specified overlap.
    public func chunk(_ text: String, size: Int, overlap: Int) -> [String] {
        guard !text.isEmpty, size > 0 else { return [] }
        let effectiveOverlap = min(max(overlap, 0), size - 1)
        let characters = Array(text)
        var chunks: [String] = []
        var start = 0
        while start < characters.count {
            let end = min(start + size, characters.count)
            chunks.append(String(characters[start..<end]))
            let step = size - effectiveOverlap
            start += max(step, 1)
            if end == characters.count { break }
        }
        return chunks
    }
}

/// The response from a RAG query.
public struct PrismRAGResponse: Sendable {
    /// The generated answer.
    public let answer: String
    /// Source text chunks used to generate the answer.
    public let sources: [String]
    /// A confidence score between 0 and 1.
    public let confidence: Double

    /// Creates a RAG response.
    public init(answer: String, sources: [String], confidence: Double) {
        self.answer = answer
        self.sources = sources
        self.confidence = confidence
    }
}

/// A protocol for embedding text into dense vectors.
public protocol PrismEmbeddingProvider: Sendable {
    /// Embeds a single text string into a dense vector.
    func embed(_ text: String) async throws -> [Float]
}

/// A protocol for generating answers from a prompt and context.
public protocol PrismGenerationProvider: Sendable {
    /// Generates an answer given a question and context passages.
    func generate(question: String, context: [String]) async throws -> String
}

/// Orchestrates the RAG workflow: chunk, embed, store, retrieve, generate.
public actor PrismRAGPipeline {
    private let config: PrismRAGConfig
    private let store: PrismEmbeddingStore
    private let chunker: PrismTextChunker
    private let embeddingProvider: PrismEmbeddingProvider
    private let generationProvider: PrismGenerationProvider
    private var chunkTexts: [String: String] = [:]

    /// Creates a RAG pipeline with the given configuration and providers.
    public init(
        config: PrismRAGConfig = PrismRAGConfig(),
        store: PrismEmbeddingStore = PrismEmbeddingStore(),
        embeddingProvider: PrismEmbeddingProvider,
        generationProvider: PrismGenerationProvider
    ) {
        self.config = config
        self.store = store
        self.chunker = PrismTextChunker()
        self.embeddingProvider = embeddingProvider
        self.generationProvider = generationProvider
    }

    /// Ingests documents by chunking, embedding, and storing them.
    public func ingest(documents: [String]) async throws {
        for document in documents {
            let chunks = chunker.chunk(document, size: config.chunkSize, overlap: config.overlapSize)
            for chunk in chunks {
                let vector = try await embeddingProvider.embed(chunk)
                let id = UUID().uuidString
                chunkTexts[id] = chunk
                let embedding = PrismEmbedding(
                    id: id,
                    vector: vector,
                    metadata: ["source": String(chunk.prefix(100))]
                )
                await store.add(embedding)
            }
        }
    }

    /// Queries the pipeline with a question and returns a generated answer with sources.
    public func query(_ question: String) async throws -> PrismRAGResponse {
        let queryVector = try await embeddingProvider.embed(question)
        let results = await store.search(query: queryVector, topK: config.topK)
        let sources = results.compactMap { chunkTexts[$0.embedding.id] }
        let answer = try await generationProvider.generate(question: question, context: sources)
        let avgSimilarity = results.isEmpty
            ? 0.0
            : Double(results.map(\.similarity).reduce(0, +)) / Double(results.count)
        return PrismRAGResponse(
            answer: answer,
            sources: sources,
            confidence: avgSimilarity
        )
    }
}
