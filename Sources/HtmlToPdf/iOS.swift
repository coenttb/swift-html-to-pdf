//
//  swift-html-to-pdf | iOS.swift
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
    ///
    public func print(
        configuration: PDFConfiguration
    ) async throws {
        let stream = AsyncStream { continuation in
            Task {
                for document in self {
                    continuation.yield(document)
                }
                continuation.finish()
            }
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for await document in stream {
                taskGroup.addTask {
                    
                    try await document.print(configuration: configuration)
                    
                }
                try await taskGroup.waitForAll()
            }
        }
    }
}

extension Document {
    /// Prints a single ``Document`` to a PDF at the given directory with the title and margins.
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
