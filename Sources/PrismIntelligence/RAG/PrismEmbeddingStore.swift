//
//  PrismEmbeddingStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A single embedding vector with associated metadata.
public struct PrismEmbedding: Sendable, Equatable, Identifiable {
    /// A unique identifier for this embedding.
    public let id: String
    /// The dense vector representation.
    public let vector: [Float]
    /// Arbitrary key-value metadata attached to this embedding.
    public let metadata: [String: String]

    /// Creates an embedding.
    public init(id: String, vector: [Float], metadata: [String: String] = [:]) {
        self.id = id
        self.vector = vector
        self.metadata = metadata
    }
}

/// A search result pairing an embedding with its similarity score.
public struct PrismSearchResult: Sendable {
    /// The matched embedding.
    public let embedding: PrismEmbedding
    /// The cosine similarity score between the query and this embedding.
    public let similarity: Float
}

/// An actor-isolated store for managing embeddings and performing similarity search.
public actor PrismEmbeddingStore {
    private var embeddings: [PrismEmbedding] = []

    /// The number of embeddings currently stored.
    public var count: Int { embeddings.count }

    /// Creates an empty embedding store.
    public init() {}

    /// Adds an embedding to the store.
    public func add(_ embedding: PrismEmbedding) {
        embeddings.append(embedding)
    }

    /// Searches for the most similar embeddings to the given query vector.
    public func search(query: [Float], topK: Int) -> [PrismSearchResult] {
        embeddings
            .map { embedding in
                PrismSearchResult(
                    embedding: embedding,
                    similarity: Self.cosineSimilarity(query, embedding.vector)
                )
            }
            .sorted { $0.similarity > $1.similarity }
            .prefix(topK)
            .map { $0 }
    }

    /// Removes all stored embeddings.
    public func clear() {
        embeddings.removeAll()
    }

    /// Computes the cosine similarity between two vectors.
    public static func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        let denominator = sqrt(normA) * sqrt(normB)
        guard denominator > 0 else { return 0 }
        return dot / denominator
    }
}
