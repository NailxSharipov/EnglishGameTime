//
//  Image+File.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 13.05.2022.
//

import SwiftUI

extension Image {
    
    init?(file: String) {
        guard let cgImage = Self.load(path: file) else {
            return nil
        }
        self.init(cgImage, scale: 1, label: Text(file))
    }
    
    private static func load(path: String) -> CGImage? {
#if os(iOS)
        return UIImage(contentsOfFile: path)?.cgImage
#elseif os(macOS)
        return NSImage(contentsOfFile: path)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
#endif
    }

}

