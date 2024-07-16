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
    
    @Test(.disabled()) func single() async throws {
        
        await withKnownIssue {
            
//           Console log:
//            FAULT: NSInternalInconsistencyException: Printing failed because PMSessionBeginCGDocumentNoDialog() returned -30872.; {
//                NSUnderlyingError = "Error Domain=NSCocoaErrorDomain Code=-30872 \"To print this file, you must set up a printer.\" UserInfo={NSLocalizedDescription=To print this file, you must set up a printer., NSLocalizedRecoverySuggestion=To set up a printer, choose Apple menu > System Settings, click Printers & Scanners, and then click the Add (+) button.}";
//            }
            
            let id = UUID()
            let directory = URL.output(id: id)
            
            try directory.createDirectories()
            
            try await htmlString.print(to: directory.appendingPathComponent("\(id.uuidString) test string").appendingPathExtension("pdf"), configuration: .a4)
            
            let contents_after = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            #expect(contents_after.count == 1)
            
            try FileManager.default.removeItems(at: directory)
        }
        
        
    }
    
    @Test func collection_n_size() async throws {
        
        let count = 10
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: htmlString, count: count)
            .print(to: output, configuration: .a4)
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == count)
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_n_size_double() async throws {
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
       
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == (count * 2) )
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_of_documents() async throws {
        
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
    
    @Test func collection_collection_individual() async throws {
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
}
#if os(macOS)

@Suite("Local")
struct Local {
    let cleanup: Bool = false
    
    @Test(.disabled()) func individual() async throws {
        await withKnownIssue {
            let output = URL.localHtmlToPdf.appendingPathComponent("individual")
            
            try await htmlString.print(title: "individual", to: output, configuration: .a4)
            
            #expect(FileManager.default.fileExists(atPath: output.path))
            
            if cleanup {
                try FileManager.default.removeItems(at: output)
            }
        }
    }
    
    @Test() func collection() async throws {
        let output = URL.localHtmlToPdf.appendingPathComponent("collection")
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
