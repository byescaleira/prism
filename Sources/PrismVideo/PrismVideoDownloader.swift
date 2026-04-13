//
//  PrismVideoDownloader.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation

public actor PrismVideoDownloader {
    private var videoURL: URL
    private var videoName: String
    private var videoType: AVFileType

    public init(
        video url: URL,
        with name: String,
        for type: AVFileType = .mp4
    ) {
        videoURL = url
        videoName = name
        videoType = type
    }

    func download() -> AsyncStream<PrismVideoDownloaderStatus> {
        AsyncStream { continuation in
            Task {
                do {
                    let asset = AVURLAsset(url: videoURL)
                    let isPlayable = try await asset.load(.isPlayable)

                    guard isPlayable else {
                        continuation.yield(PrismVideoDownloaderStatus.error(.assetNotPlayable))
                        continuation.finish()
                        return
                    }

                    let composition = AVMutableComposition()
                    guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first,
                        let audioTrack = try await asset.loadTracks(withMediaType: .audio).first
                    else {
                        continuation.yield(PrismVideoDownloaderStatus.error(.missingTracks))
                        continuation.finish()
                        return
                    }

                    let timeRange = try await CMTimeRange(start: .zero, duration: asset.load(.duration))
                    let videoCompTrack = composition.addMutableTrack(
                        withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                    let audioCompTrack = composition.addMutableTrack(
                        withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

                    try videoCompTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
                    try audioCompTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)

                    let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent(
                        videoName + videoType.rawValue)

                    guard
                        let exportSession = AVAssetExportSession(
                            asset: composition,
                            presetName: AVAssetExportPresetHighestQuality
                        )
                    else {
                        continuation.yield(PrismVideoDownloaderStatus.error(.failedToCreateExportSession))
                        continuation.finish()
                        return
                    }
                    exportSession.shouldOptimizeForNetworkUse = true

                    let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                    let cancellable = progressTimer.sink { _ in
                        let progress = Double(exportSession.progress)
                        continuation.yield(
                            PrismVideoDownloaderStatus.downloading(
                                progress: progress,
                                session: exportSession
                            )
                        )
                    }

                    try await exportSession.export(to: exportURL, as: videoType)
                    cancellable.cancel()
                    continuation.yield(PrismVideoDownloaderStatus.completed(path: exportURL))
                    continuation.finish()
                } catch {
                    continuation.yield(PrismVideoDownloaderStatus.error(.custom(message: error.localizedDescription)))
                    continuation.finish()
                }
            }
        }
    }
}
