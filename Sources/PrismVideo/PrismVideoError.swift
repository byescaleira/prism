//
//  PrismVideoError.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import PrismFoundation

public enum PrismVideoError: PrismError, Sendable {
    case assetNotPlayable
    case missingTracks
    case failedToCreateExportSession
    case custom(message: String)

    public var description: String {
        errorDescription ?? ""
    }

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
