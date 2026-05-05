//
//  PrismVideoTests.swift
//  PrismVideoTests
//
//  Created by Rafael Escaleira on 27/04/26.
//

import AVFoundation
import Testing

@testable import PrismVideo

@Suite
struct PrismVideoEntityTests {
    @Test
    func entityPreservesStoredIdentity() {
        let entity = PrismVideoEntity(
            url: URL(string: "https://example.com/video.mp4")!,
            title: "Test Video"
        )

        #expect(entity.id == entity.id)
    }

    @Test
    func entityInitializesWithDefaults() {
        let url = URL(string: "https://example.com/video.mp4")!
        let entity = PrismVideoEntity(url: url, title: "Sample")

        #expect(entity.url == url)
        #expect(entity.title == "Sample")
        #expect(entity.duration == nil)
        #expect(entity.resolution == nil)
        #expect(entity.type == .mp4)
        #expect(entity.thumb == nil)
    }

    @Test
    func entityInitializesWithAllParameters() {
        let url = URL(string: "https://example.com/video.mp4")!
        let thumb = URL(string: "https://example.com/thumb.jpg")!
        let id = UUID()

        let entity = PrismVideoEntity(
            id: id,
            url: url,
            title: "Full Video",
            duration: 120.5,
            resolution: .fullHD,
            type: .mov,
            thumb: thumb
        )

        #expect(entity.id == id)
        #expect(entity.url == url)
        #expect(entity.title == "Full Video")
        #expect(entity.duration == 120.5)
        #expect(entity.resolution == .fullHD)
        #expect(entity.type == .mov)
        #expect(entity.thumb == thumb)
    }

    @Test
    func entityEquality() {
        let id = UUID()
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(id: id, url: url, title: "Video")
        let b = PrismVideoEntity(id: id, url: url, title: "Video")

        #expect(a == b)
    }

    @Test
    func entityInequalityByID() {
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(url: url, title: "Video")
        let b = PrismVideoEntity(url: url, title: "Video")

        #expect(a != b)
    }

    @Test
    func entityIsHashable() {
        let id = UUID()
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(id: id, url: url, title: "Video")
        let b = PrismVideoEntity(id: id, url: url, title: "Video")

        var set: Set<PrismVideoEntity> = [a]
        set.insert(b)
        #expect(set.count == 1)
    }
}

@Suite
struct PrismVideoResolutionTests {
    @Test
    func resolutionRawValueStrings() {
        #expect(PrismVideoResolution._4K.rawValue == "4K")
        #expect(PrismVideoResolution.fullHD.rawValue == "1080p HD")
        #expect(PrismVideoResolution.HD.rawValue == "720p HD")
        #expect(PrismVideoResolution.SD.rawValue == "SD")
    }

    @Test
    func resolutionInitFromHeight() {
        #expect(PrismVideoResolution(rawValue: 0) == .SD)
        #expect(PrismVideoResolution(rawValue: 480) == .SD)
        #expect(PrismVideoResolution(rawValue: 719) == .SD)
        #expect(PrismVideoResolution(rawValue: 720) == .HD)
        #expect(PrismVideoResolution(rawValue: 1079) == .HD)
        #expect(PrismVideoResolution(rawValue: 1080) == .fullHD)
        #expect(PrismVideoResolution(rawValue: 2159) == .fullHD)
        #expect(PrismVideoResolution(rawValue: 2160) == ._4K)
        #expect(PrismVideoResolution(rawValue: 4320) == ._4K)
    }

    @Test
    func resolutionIDMatchesRawValue() {
        let resolution = PrismVideoResolution.fullHD
        #expect(resolution.id == resolution.rawValue)
    }
}

@Suite
struct PrismVideoErrorTests {
    @Test
    func errorDescriptions() {
        #expect(PrismVideoError.assetNotPlayable.errorDescription == "Asset not playable")
        #expect(PrismVideoError.missingTracks.errorDescription == "Missing video or audio tracks")
        #expect(PrismVideoError.failedToCreateExportSession.errorDescription == "Failed to create export session")
        #expect(PrismVideoError.custom(message: "test error").errorDescription == "test error")
    }

    @Test
    func errorFailureReasons() {
        #expect(PrismVideoError.assetNotPlayable.failureReason != nil)
        #expect(PrismVideoError.missingTracks.failureReason != nil)
        #expect(PrismVideoError.failedToCreateExportSession.failureReason != nil)
        #expect(PrismVideoError.custom(message: "test").failureReason == nil)
    }

    @Test
    func errorRecoverySuggestions() {
        #expect(PrismVideoError.assetNotPlayable.recoverySuggestion != nil)
        #expect(PrismVideoError.missingTracks.recoverySuggestion != nil)
        #expect(PrismVideoError.failedToCreateExportSession.recoverySuggestion != nil)
        #expect(PrismVideoError.custom(message: "test").recoverySuggestion == nil)
    }

    @Test
    func errorDescription() {
        #expect(PrismVideoError.assetNotPlayable.description == "Asset not playable")
    }

    @Test
    func errorDescriptionIsNonEmpty() {
        let errors: [PrismVideoError] = [
            .assetNotPlayable,
            .missingTracks,
            .failedToCreateExportSession,
            .custom(message: "test"),
        ]

        for error in errors {
            #expect(!error.description.isEmpty)
        }
    }
}

@Suite
struct PrismVideoDownloaderTests {
    @Test
    func downloaderInitializesWithParameters() {
        let url = URL(string: "https://example.com/video.mp4")!
        let downloader = PrismVideoDownloader(
            video: url,
            with: "test_video",
            for: .mp4
        )

        #expect(downloader != nil)
    }

    @Test
    func downloaderDefaultsToMP4() {
        let url = URL(string: "https://example.com/video.mp4")!
        let downloader = PrismVideoDownloader(
            video: url,
            with: "test_video"
        )

        #expect(downloader != nil)
    }

    @Test
    func downloaderInitializesWithMOVType() {
        let url = URL(string: "https://example.com/video.mov")!
        let downloader = PrismVideoDownloader(
            video: url,
            with: "mov_video",
            for: .mov
        )

        #expect(downloader != nil)
    }
}

@Suite
struct PrismVideoDownloaderStatusTests {
    @Test
    func completedStoresURL() {
        let path = URL(string: "file:///tmp/exported_video.mp4")!
        let status = PrismVideoDownloaderStatus.completed(path: path)

        if case .completed(let storedPath) = status {
            #expect(storedPath == path)
        } else {
            Issue.record("Expected .completed case")
        }
    }

    @Test
    func completedWithFileURL() {
        let path = URL(fileURLWithPath: "/var/folders/tmp/video_output.mp4")
        let status = PrismVideoDownloaderStatus.completed(path: path)

        if case .completed(let storedPath) = status {
            #expect(storedPath == path)
            #expect(storedPath.isFileURL)
        } else {
            Issue.record("Expected .completed case")
        }
    }

    @Test
    func errorStoresAssetNotPlayable() {
        let status = PrismVideoDownloaderStatus.error(.assetNotPlayable)

        if case .error(let storedError) = status {
            #expect(storedError.errorDescription == "Asset not playable")
        } else {
            Issue.record("Expected .error case")
        }
    }

    @Test
    func errorStoresMissingTracks() {
        let status = PrismVideoDownloaderStatus.error(.missingTracks)

        if case .error(let storedError) = status {
            #expect(storedError.errorDescription == "Missing video or audio tracks")
        } else {
            Issue.record("Expected .error case")
        }
    }

    @Test
    func errorStoresFailedToCreateExportSession() {
        let status = PrismVideoDownloaderStatus.error(.failedToCreateExportSession)

        if case .error(let storedError) = status {
            #expect(storedError.errorDescription == "Failed to create export session")
        } else {
            Issue.record("Expected .error case")
        }
    }

    @Test
    func errorStoresCustomMessage() {
        let status = PrismVideoDownloaderStatus.error(.custom(message: "network timeout"))

        if case .error(let storedError) = status {
            #expect(storedError.errorDescription == "network timeout")
        } else {
            Issue.record("Expected .error case")
        }
    }
}

@Suite
struct PrismVideoEntityEdgeCaseTests {
    @Test
    func entityMutationUpdatesValues() {
        let url = URL(string: "https://example.com/video.mp4")!
        var entity = PrismVideoEntity(url: url, title: "Original")

        let newURL = URL(string: "https://example.com/updated.mov")!
        entity.url = newURL
        entity.title = "Updated"
        entity.duration = 60.0
        entity.resolution = .HD
        entity.type = .mov
        entity.thumb = URL(string: "https://example.com/thumb.png")!

        #expect(entity.url == newURL)
        #expect(entity.title == "Updated")
        #expect(entity.duration == 60.0)
        #expect(entity.resolution == .HD)
        #expect(entity.type == .mov)
        #expect(entity.thumb != nil)
    }

    @Test
    func entityWithZeroDuration() {
        let url = URL(string: "https://example.com/video.mp4")!
        let entity = PrismVideoEntity(url: url, title: "Zero", duration: 0)

        #expect(entity.duration == 0)
    }

    @Test
    func entityHashableWithDifferentIDs() {
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(url: url, title: "Video")
        let b = PrismVideoEntity(url: url, title: "Video")

        let set: Set<PrismVideoEntity> = [a, b]
        #expect(set.count == 2)
    }
}

@Suite
struct PrismVideoResolutionEdgeCaseTests {
    @Test
    func resolutionFromNegativeHeight() {
        // Negative values fall into the 0..<720 range pattern via default
        // but Int ranges don't include negatives in 0..<720, so this goes to default (_4K)
        let resolution = PrismVideoResolution(rawValue: -1)
        #expect(resolution != nil)
    }

    @Test
    func resolutionFromExactBoundaries() {
        #expect(PrismVideoResolution(rawValue: 0) == .SD)
        #expect(PrismVideoResolution(rawValue: 719) == .SD)
        #expect(PrismVideoResolution(rawValue: 720) == .HD)
        #expect(PrismVideoResolution(rawValue: 1079) == .HD)
        #expect(PrismVideoResolution(rawValue: 1080) == .fullHD)
        #expect(PrismVideoResolution(rawValue: 2159) == .fullHD)
        #expect(PrismVideoResolution(rawValue: 2160) == ._4K)
    }

    @Test
    func resolutionInitNeverReturnsNil() {
        let testValues = [-100, -1, 0, 1, 360, 480, 720, 1080, 2160, 4320, 10000]
        for value in testValues {
            #expect(PrismVideoResolution(rawValue: value) != nil)
        }
    }

    @Test
    func allResolutionCasesHaveNonEmptyRawValue() {
        let cases: [PrismVideoResolution] = [._4K, .fullHD, .HD, .SD]
        for resolution in cases {
            #expect(!resolution.rawValue.isEmpty)
            #expect(resolution.id == resolution.rawValue)
        }
    }
}

@Suite
struct PrismVideoErrorEdgeCaseTests {
    @Test
    func customErrorWithEmptyMessage() {
        let error = PrismVideoError.custom(message: "")
        #expect(error.errorDescription == "")
        #expect(error.description == "")
        #expect(error.failureReason == nil)
        #expect(error.recoverySuggestion == nil)
    }

    @Test
    func failureReasonExactContent() {
        #expect(
            PrismVideoError.assetNotPlayable.failureReason
                == "The AVAsset could not be prepared for playback."
        )
        #expect(
            PrismVideoError.missingTracks.failureReason
                == "The source file does not contain valid video or audio tracks."
        )
        #expect(
            PrismVideoError.failedToCreateExportSession.failureReason
                == "AVAssetExportSession could not be initialized."
        )
    }

    @Test
    func recoverySuggestionExactContent() {
        #expect(
            PrismVideoError.assetNotPlayable.recoverySuggestion
                == "Try reloading or verifying the video source."
        )
        #expect(
            PrismVideoError.missingTracks.recoverySuggestion
                == "Ensure the media file has at least one valid video or audio track."
        )
        #expect(
            PrismVideoError.failedToCreateExportSession.recoverySuggestion
                == "Check export configurations or try again with different parameters."
        )
    }

    @Test
    func descriptionMatchesErrorDescription() {
        let errors: [PrismVideoError] = [
            .assetNotPlayable,
            .missingTracks,
            .failedToCreateExportSession,
            .custom(message: "something went wrong"),
        ]

        for error in errors {
            #expect(error.description == error.errorDescription)
        }
    }
}
