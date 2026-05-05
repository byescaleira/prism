//
//  PrismVideoEntity.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import PrismFoundation

/// Entity representing video metadata.
public struct PrismVideoEntity: Identifiable, Equatable, Hashable, Sendable {
    /// The unique identifier for this video entity.
    public let id: UUID
    /// The remote or local URL of the video file.
    public var url: URL
    /// The display title of the video.
    public var title: String
    /// The duration of the video in seconds, if known.
    public var duration: TimeInterval?
    /// The resolution of the video, if known.
    public var resolution: PrismVideoResolution?
    /// The container file type of the video.
    public var type: AVFileType
    /// The URL of the video's thumbnail image, if available.
    public var thumb: URL?

    /// Creates a new video entity with the given metadata.
    public init(
        id: UUID = UUID(),
        url: URL,
        title: String,
        duration: TimeInterval? = nil,
        resolution: PrismVideoResolution? = nil,
        type: AVFileType = .mp4,
        thumb: URL? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.duration = duration
        self.resolution = resolution
        self.type = type
        self.thumb = thumb
    }
}
