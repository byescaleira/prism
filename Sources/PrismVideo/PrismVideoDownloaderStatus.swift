//
//  PrismVideoDownloaderStatus.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import PrismFoundation

/// Status of a video download: progress, completion, or error.
///
/// `@unchecked Sendable` because `AVAssetExportSession` is not Sendable.
/// The session reference is only used for cancellation and progress observation
/// and must not be shared across isolation domains without coordination.
public enum PrismVideoDownloaderStatus: @unchecked Sendable {
    case downloading(
        progress: Double,
        session: AVAssetExportSession
    )
    case completed(path: URL)
    case error(PrismVideoError)
}
