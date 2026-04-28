//
//  PrismVisionClassifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

#if canImport(Vision) && canImport(CoreGraphics)
import CoreGraphics
import Vision

/// A single classification result with label and confidence.
public struct PrismClassificationResult: Sendable, Equatable {
    /// The classification label.
    public let label: String
    /// The confidence score between 0 and 1.
    public let confidence: Double

    /// Creates a classification result.
    public init(label: String, confidence: Double) {
        self.label = label
        self.confidence = confidence
    }
}

/// Classifies images using the Vision framework.
public struct PrismVisionClassifier: Sendable {
    /// Creates a vision classifier.
    public init() {}

    /// Classifies a CGImage and returns the top results.
    public func classify(image: CGImage, maxResults: Int = 5) async throws -> [PrismClassificationResult] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = (request.results as? [VNClassificationObservation]) ?? []
                let results = observations
                    .sorted { $0.confidence > $1.confidence }
                    .prefix(maxResults)
                    .map { PrismClassificationResult(label: $0.identifier, confidence: Double($0.confidence)) }
                continuation.resume(returning: Array(results))
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Classifies image data and returns the top results.
    public func classify(imageData: Data, maxResults: Int = 5) async throws -> [PrismClassificationResult] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = (request.results as? [VNClassificationObservation]) ?? []
                let results = observations
                    .sorted { $0.confidence > $1.confidence }
                    .prefix(maxResults)
                    .map { PrismClassificationResult(label: $0.identifier, confidence: Double($0.confidence)) }
                continuation.resume(returning: Array(results))
            }

            let handler = VNImageRequestHandler(data: imageData, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

#endif
