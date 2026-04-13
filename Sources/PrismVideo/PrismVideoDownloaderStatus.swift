//
//  PrismVideoDownloaderStatus.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import PrismFoundation

public enum PrismVideoDownloaderStatus: @unchecked Sendable {
    case downloading(
        progress: Double,
        session: AVAssetExportSession
    )
    case completed(path: URL)
    case error(PrismVideoError)
}
