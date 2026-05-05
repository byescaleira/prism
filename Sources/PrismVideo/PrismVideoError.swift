//
//  PrismVideoError.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import PrismFoundation

/// Typed errors for video download operations.
public enum PrismVideoError: PrismError, Sendable {
    /// The AVAsset could not be loaded for playback.
    case assetNotPlayable
    /// The source file is missing required video or audio tracks.
    case missingTracks
    /// An AVAssetExportSession could not be created.
    case failedToCreateExportSession
    /// A custom error with a freeform message.
    case custom(message: String)

    /// A short human-readable description of the error.
    public var description: String {
        errorDescription ?? ""
    }

    /// A localized description of the error suitable for display.
    public var errorDescription: String? {
        switch self {
        case .assetNotPlayable:
            return "Asset not playable"
        case .missingTracks:
            return "Missing video or audio tracks"
        case .failedToCreateExportSession:
            return "Failed to create export session"
        case .custom(let message):
            return message
        }
    }

    /// A detailed explanation of why the error occurred.
    public var failureReason: String? {
        switch self {
        case .assetNotPlayable:
            return "The AVAsset could not be prepared for playback."
        case .missingTracks:
            return "The source file does not contain valid video or audio tracks."
        case .failedToCreateExportSession:
            return "AVAssetExportSession could not be initialized."
        default:
            return nil
        }
    }

    /// A suggested action the caller can take to recover from the error.
    public var recoverySuggestion: String? {
        switch self {
        case .assetNotPlayable:
            return "Try reloading or verifying the video source."
        case .missingTracks:
            return "Ensure the media file has at least one valid video or audio track."
        case .failedToCreateExportSession:
            return "Check export configurations or try again with different parameters."
        default:
            return nil
        }
    }
}
