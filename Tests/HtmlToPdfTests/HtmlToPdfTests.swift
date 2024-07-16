//
//  HtmlToPdfTests.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

import Foundation
import HtmlToPdf
import Testing

struct TemporaryDirectory {
    @Test func single() async throws {
        
        let id = UUID()
        let output = URL.output(id: id).appendingPathComponent(id.uuidString).appendingPathExtension("pdf")
        let htmlString = "<html><body><h1>Hello, World!</h1></body></html>"
        
        try await htmlString.print(to: output)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        try FileManager.default.removeItems(at: output.deletingPathExtension().deletingLastPathComponent())
    }
    
    @Test func collection() async throws {
        
        let count = 1000
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: "<html><body><h1>Hello, World 1!</h1></body></html>", count: count)
            .print(to: output)
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == count)
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_2() async throws {
        let count = 10
        
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: "<html><body><h1>Hello, World 1!</h1></body></html>", count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )
        
        try await [String].init(repeating: "<html><body><h1>Hello, World 2!</h1></body></html>", count: count)
            .print(
                to: output,
                filename: { _ in UUID().uuidString }
            )
        
        try await "<html><body><h1>Hello, World!</h1></body></html>".print(
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
                html: "<html><body><h1>Hello, World 1!</h1></body></html>"
            ),
            Document(
                url: output.appendingPathComponent("file2").appendingPathExtension("pdf"),
                html: "<html><body><h1>Hello, World 2!</h1></body></html>"
            ),
            Document(
                url: output.appendingPathComponent("file3").appendingPathExtension("pdf"),
                html: "<html><body><h1>Hello, World 1!</h1></body></html>"
            ),
            Document(
                url: output.appendingPathComponent("file4").appendingPathExtension("pdf"),
                html: "<html><body><h1>Hello, World 2!</h1></body></html>"
            ),
            Document(
                url: output.appendingPathComponent("file5").appendingPathExtension("pdf"),
                html: "<html><body><h1>Hello, World 1!</h1></body></html>"
            ),
            Document(
                url: output.appendingPathComponent("file6").appendingPathExtension("pdf"),
                html: "<html><body><h1>Hello, World 2!</h1></body></html>"
            ),
        ]
        
        try await documents.print(
                to: output,
                configuration: .a4
            )
        
//        await [String].init(repeating: "<html><body><h1>Hello, World 2!</h1></body></html>", count: count)
//            .print(
//                to: output,
//                filename: { _ in UUID().uuidString }
//            )
//        
//        try await "<html><body><h1>Hello, World!</h1></body></html>".print(
//            title: UUID().uuidString,
//            to: output,
//            configuration: .a4
//        )
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == documents.count)
        
        try FileManager.default.removeItems(at: output)
    }
}
#if os(macOS)

@Suite("Local", .disabled("enable this if you want to quickly see pdfs printed to your local documents directory"))
struct Local {
    
    let cleanup: Bool = false
    
    @Test func local_individual() async throws {
        let output = URL.localHtmlToPdf
        let htmlString = "<html><body><h1>Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! </h1></body></html>"
        
        try await htmlString.print(title: "individual", to: output)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        if cleanup {
            try FileManager.default.removeItems(at: output)
        }
    }
    
    @Test func local_collection() async throws {
        let output = URL.localHtmlToPdf
        
        try await [String].init(repeating: .hello_world_html, count: 10)
            .print(to: output)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        if cleanup {
            try FileManager.default.removeItems(at: output)
        }
    }
}
#endif
