//
//  HtmlToPdfTests.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

import Foundation
import HtmlToPdf
import Testing

@Suite("Temporary")
struct TemporaryDirectory {
    
    @Test func single() async throws {
        
        let id = UUID()
        let directory = URL.output(id: id)
        let output = directory
        
        try directory.createDirectories()
        
        try await htmlString.print(to: directory.appendingPathComponent("\(id.uuidString) test string").appendingPathExtension("pdf"), configuration: .a4)
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == 1)
        
        try FileManager.default.removeItems(at: directory)
    }
    
    @Test func collection() async throws {
        
        let count = 10
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: htmlString, count: count)
            .print(to: output, configuration: .a4)
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == count)
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_2() async throws {
        let count = 10
        
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: htmlString, count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )
        
        try await [String].init(repeating: htmlString, count: count)
            .print(
                to: output, configuration: .a4,
                filename: { _ in UUID().uuidString }
            )
        
        try await htmlString.print(
            title: UUID().uuidString,
            to: output,
            configuration: .a4
        )
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == (count * 2) + 1 )
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_3() async throws {
        
        let output = URL.output()
        
        try output.createDirectories()
        
        let documents = [
            Document(
                url: output.appendingPathComponent("file1").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file2").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file3").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file4").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file5").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file6").appendingPathExtension("pdf"),
                html: htmlString
            ),
        ]
        
        try await documents.print(
            configuration: .a4
        )
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == documents.count)
        
        try FileManager.default.removeItems(at: output)
    }
}
#if os(macOS)

@Suite("Local")
struct Local {
    let cleanup: Bool = false
    
    @Test func individual() async throws {
        let output = URL.localHtmlToPdf
        
        try await htmlString.print(title: "individual", to: output, configuration: .a4)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        if cleanup {
            try FileManager.default.removeItems(at: output)
        }
    }
    
    @Test() func collection() async throws {
        let output = URL.localHtmlToPdf
        let count = 10
        
        try output.createDirectories()
        
        try await [String].init(repeating: htmlString, count: count)
            .print(
                to: output,
                configuration: .init(
                    paperSize: .paperSize(),
                    margins: .a4
                )
            )
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        for content in contents_after {
            print("\(content)")
        }
        
        #expect(contents_after.count == count)
        
        
        if cleanup {
            try FileManager.default.removeItems(at: output)
        }
    }
}
#endif
