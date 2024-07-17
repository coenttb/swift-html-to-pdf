//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if os(iOS)

import Foundation
import UIKit
import WebKit

extension [Document] {
    /// Prints documents  to pdf's at the given directory.
    ///
    /// ## Example
    /// ```swift
    /// let htmls = [
    ///     "<html><body><h1>Hello, World 1!</h1></body></html>",
    ///     "<html><body><h1>Hello, World 1!</h1></body></html>",
    ///     ...
    /// ]
    /// try await htmls.print(to: .downloadsDirectory)
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: The configuration that the pdfs will use.
    ///   - processorCount: In allmost all circumstances you can omit this parameter.
    ///
    public func print(
        configuration: PDFConfiguration,
        processorCount: Int = ProcessInfo.processInfo.activeProcessorCount
    ) async throws {
        let stream = AsyncStream { continuation in
            Task {
                for document in self {
                    continuation.yield(document)
                }
                continuation.finish()
            }
        }
        
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for _ in 0..<processorCount {
                taskGroup.addTask {
                    for await document in stream {
                        try await document.html.print(
                            to: document.url
                                .deletingPathExtension()
                                .appendingPathExtension("pdf"),
                            configuration: configuration
                        )
                    }
                }
            }
        }
    }
}

extension String {
    /// Prints a single html string to a pdf at the given directory with the title and margins.
    ///
    /// ## Example
    /// ```swift
    ///  let html = "<html><body><h1>Hello, World!</h1></body></html>"
    ///  try await html.print(
    ///     title: "helloWorld",
    ///     to: .downloadsDirectory
    ///  )
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title of the pdf
    ///   - directory: The directory at which to print the pdf
    ///   - margins: The margins of the pdf document, defaulting to a4.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    ///
    public func print(
        title: String,
        to directory: URL,
        configuration: PDFConfiguration
    ) async throws {
        try await self.print(
            to: directory.appendingPathComponent(title).appendingPathExtension("pdf"),
            configuration: configuration
        )
    }
}

extension String {
    @MainActor
    public func print(
        to url: URL,
        configuration: PDFConfiguration
    ) async throws {
        let html = self

        let renderer = UIPrintPageRenderer.init()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: html)
        
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let paperRect = CGRect.init(origin: .zero, size: configuration.paperSize)

        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: configuration.printableRect), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSRange(location: 0, length: renderer.numberOfPages))

        let bounds = UIGraphicsGetPDFContextBounds()

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: bounds)
        }

        UIGraphicsEndPDFContext()

        try pdfData.write(to: url)
    }
}

extension PDFConfiguration {
    public static func a4(margins: EdgeInsets) -> PDFConfiguration {
        return .init(
            margins: margins,
            paperSize: .a4()
        )
    }
}

extension CGSize {
    public static func paperSize() -> CGSize {
        CGSize(width: 595.22, height: 841.85)
    }
}

extension UIEdgeInsets {
    init(
        edgeInsets: EdgeInsets
    ){
        self = .init(
            top: .init(edgeInsets.top),
            left: .init(edgeInsets.left),
            bottom: .init(edgeInsets.bottom),
            right: .init(edgeInsets.right)
        )
    }
}

#endif
