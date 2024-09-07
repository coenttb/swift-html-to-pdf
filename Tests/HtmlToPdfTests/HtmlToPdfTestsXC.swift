//
//  HtmlToPdfTestsXC.swift
//  
//
//  Created by John Santos on 07/09/2024.
//

import XCTest
@testable import HtmlToPdf

final class HtmlToPdfTestsXC: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func test_collection() async throws {
        let count = 1_000

        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }
        try await [String].init(
            repeating: "<html><body><h1>Hello, World 1!</h1></body></html>",
            count: count
        )
        .print(to: output)

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, count)
    }

    func test_individual() async throws {
        let id = UUID()
        let output = URL.output(id: id).appendingPathComponent("individual")
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await String.html.print(to: output.appendingPathComponent("\(id.uuidString) test string").appendingPathExtension("pdf"), configuration: .a4)

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, 1)
    }

    func test_collection_n_size() async throws {
        let count = 10
        let output = URL.output()
        defer { if true { try! FileManager.default.removeItem(at: output) } }

        try await [String].init(repeating: .html, count: count)
            .print(to: output, configuration: .a4)

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, count)
    }

    func test_collection_n_size_concurrently() async throws {
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

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, (count * 2) )
    }

    func test_collection_of_documents() async throws {
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

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, documents.count)
    }

    func test_collection_collection_individual() async throws {
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

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, (count * 2) + 1 )
    }

    func test_collection_3() async throws {
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

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil).count, documents.count + count + 1)
    }
}
