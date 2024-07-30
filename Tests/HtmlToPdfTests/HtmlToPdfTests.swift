//
//  HtmlToPdfTests.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

import Foundation
@testable import HtmlToPdf
import Testing

@Suite("Temporary")
struct TemporaryDirectory {

    @Test func collection() async throws {
        let count = 1_000

        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }
        try await [String].init(
            repeating: "<html><body><h1>Hello, World 1!</h1></body></html>",
            count: count
        )
        .print(to: output)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == count)
    }

    @Test() func individual() async throws {
        let id = UUID()
        let output = URL.output(id: id).appendingPathComponent("individual")
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await String.html.print(to: output.appendingPathComponent("\(id.uuidString) test string").appendingPathExtension("pdf"), configuration: .a4)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == 1)
    }

    @Test func collection_n_size() async throws {
        let count = 10
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await [String].init(repeating: .html, count: count)
            .print(to: output, configuration: .a4)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == count)
    }

    @Test func collection_n_size_concurrently() async throws {
        let count = 10
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await [String].init(repeating: .html, count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        try await [String].init(repeating: .html, count: count)
            .print(
                to: output, configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == (count * 2) )
    }

    @Test func collection_of_documents() async throws {
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        let documents = [
            Document(
                fileUrl: output.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf"),
                html: .html
            )
        ]

        try await documents.print(
            configuration: .a4
        )

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == documents.count)
    }

    @Test func collection_collection_individual() async throws {
        let count = 10
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await [String].init(repeating: .html, count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        try await [String].init(repeating: .html, count: count)
            .print(
                to: output, configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        try await String.html.print(
            title: UUID().uuidString,
            to: output,
            configuration: .a4
        )

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == (count * 2) + 1 )
    }

    @Test func collection_3() async throws {
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        let documents = [
            Document(
                fileUrl: output.appendingPathComponent("file1").appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent("file2").appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent("file3").appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent("file4").appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent("file5").appendingPathExtension("pdf"),
                html: .html
            ),
            Document(
                fileUrl: output.appendingPathComponent("file6").appendingPathExtension("pdf"),
                html: .html
            )
        ]

        try await documents.print(
            configuration: .a4
        )

        let count = 10

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

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == documents.count + count + 1)

    }
}

#if os(macOS) || targetEnvironment(macCatalyst)
@Suite("Local")
struct Local {
    @Test() func individual() async throws {
        let title = "individual"
        let output = URL.localHtmlToPdf.appendingPathComponent(title)
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await String.html.print(title: title, to: output, configuration: .a4)

        #expect(FileManager.default.fileExists(atPath: output.path))
    }

    @Test() func collection_of_strings() async throws {
        let title = "collection_of_strings"
        let output = URL.localHtmlToPdf.appendingPathComponent(title)
        defer { if true { try! FileManager.default.removeItem(at: output) } }
        let count = 3

        try await [String].init(repeating: .html, count: count)
            .print(to: output)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == count)
    }

    @Test() func collection_of_documents() async throws {
        let title = "collection_of_documents"
        let output = URL.localHtmlToPdf.appendingPathComponent(title)
        defer { if true { try! FileManager.default.removeItem(at: output) } }
        let count = 3

        try await (1...count).map { count in
            Document(fileUrl: output.appendingPathComponent("\(count)").appendingPathExtension("pdf"), html: .html)
        }.print(configuration: .a4)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == count)

    }
}
#endif

@Suite("AsyncStream")
struct AsyncStreamTests {
    @Test func collection_n_size() async throws {

        let count = 1
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        let urls: AsyncStream = try await [String].init(repeating: .html, count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        try await urls.testIfYieldedUrlExistsOnFileSystem(directory: output)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == count)

    }

    @Test(
        "collection_n_size_concurrently",
        arguments: [
            URL.localHtmlToPdf.appendingPathComponent("local_collection_n_size_concurrently"),
            URL.output()
        ]
    ) func local_collection_n_size_concurrently(url: URL) async throws {
        let count = 30
        let output = url
        defer { if true { try! FileManager.default.removeItem(at: url) } }

        async let x: AsyncStream<URL> = try [String].init(repeating: .html, count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        async let y: AsyncStream = try [String].init(repeating: .html, count: count)
            .print(
                to: output, configuration: .a4,
                filename: { _ in UUID().uuidString }
            )

        try await x.testIfYieldedUrlExistsOnFileSystem(directory: output)

        try await y.testIfYieldedUrlExistsOnFileSystem(directory: output)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == (count * 2) )

    }

    @Test() func collection_of_documents() async throws {

        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }
        let count = 3

        let urls: AsyncStream = try await (1...count).map { count in
            Document(fileUrl: output.appendingPathComponent("\(count)").appendingPathExtension("pdf"), html: .html)
        }.print(configuration: .a4)

        try await urls.testIfYieldedUrlExistsOnFileSystem(directory: output)

        #expect(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count == count)
    }
}
