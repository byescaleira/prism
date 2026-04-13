//
//  PrismNetworkHeaderType.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

public enum PrismNetworkHeaderType: String, Sendable, CaseIterable {
    case json = "application/json"
    case xml = "application/xml"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case plainText = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case javascript = "application/javascript"
    case octetStream = "application/octet-stream"
    case pdf = "application/pdf"
    case zip = "application/zip"
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case svg = "image/svg+xml"
    case mp3 = "audio/mpeg"
    case mp4 = "video/mp4"
    case any = "*/*"
    case image = "image/*"
    case audio = "audio/*"
    case video = "video/*"
}
