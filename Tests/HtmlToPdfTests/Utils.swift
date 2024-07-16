//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

import Foundation
import HtmlToPdf




extension URL {
    static func output(id: UUID = .init()) -> Self {
        FileManager.default.temporaryDirectory.appendingPathComponent("html-to-pdf").appendingPathComponent(id.uuidString)
    }
    
    static let localHtmlToPdf: Self = URL.documentsDirectory.appendingPathComponent("HtmlToPdf")
}

extension URL {
    func createDirectories() throws {
        try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
    }
}

extension FileManager {
    func removeItems(at url: URL) throws {
        let fileURLs = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            try removeItem(at: fileURL)
        }
    }
}


extension String {
    static let hello_world_html: Self = "<html><body><h1>Hello, World!</h1></body></html>"
}
