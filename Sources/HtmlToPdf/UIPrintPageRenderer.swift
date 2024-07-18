//
//  swift-html-to-pdf | iOS.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if canImport(UIKit)

import Foundation
import UIKit
import WebKit

extension Sequence<Document> {
    /// Prints a sequence of ``Document``  to PDFs at the given directory.
    ///
    /// ## Example
    /// ```swift
    /// let documents = [
    ///     Document(...),
    ///     Document(...),
    ///     Document(...),
    ///     ...
    /// ]
    /// try await documents.print(to: .downloadsDirectory)
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: The configuration that the pdfs will use.
    ///   - createDirectories: If true, the function will call FileManager.default.createDirectory for each document's directory.
    ///
    public func print(
        configuration: PDFConfiguration,
        createDirectories: Bool = true
    ) async throws {
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for document in self {
                taskGroup.addTask {
                    if createDirectories {
                        try FileManager.default.createDirectory(at: document.fileUrl.deletingPathExtension().deletingLastPathComponent(), withIntermediateDirectories: true)
                    }
                    try await document.print(configuration: configuration)
                }
            }
        }
    }
}

extension Document {
    /// Prints a ``Document`` to PDF with the given configuration.
    ///
    /// This function is more convenient when you have a directory and just want to title the PDF and save it to the directory.
    ///
    /// ## Example
    /// ```swift
    /// try await Document.init(...)
    ///     .print(configuration: .a4)
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: The configuration of the PDF document.
    ///
    /// - Throws: `Error` if the function cannot write to the document's fileUrl.
    @MainActor
    public func print(
        configuration: PDFConfiguration
    ) async throws {
        
        try FileManager.default.createDirectory(at: self.fileUrl.deletingPathExtension().deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let renderer = UIPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: self.html)

        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let paperRect = CGRect(origin: .zero, size: configuration.paperSize)

        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: configuration.printableRect), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSRange(location: 0, length: renderer.numberOfPages))

        let bounds = UIGraphicsGetPDFContextBounds()

        (0..<renderer.numberOfPages).forEach { index in
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: index, in: bounds)
        }

        UIGraphicsEndPDFContext()

        try pdfData.write(to: self.fileUrl)
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
    ) {
        self = .init(
            top: .init(edgeInsets.top),
            left: .init(edgeInsets.left),
            bottom: .init(edgeInsets.bottom),
            right: .init(edgeInsets.right)
        )
    }
}

#endif
