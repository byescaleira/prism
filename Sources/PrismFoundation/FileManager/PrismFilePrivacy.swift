//
//  PrismFilePrivacy.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/09/25.
//

/// Defines the visibility of a file in the file system.
public enum PrismFilePrivacy: String {
    /// The file is stored in the public documents directory.
    case `public` = ""
    /// The file is stored in a hidden private subdirectory.
    case `private` = ".private"
}
