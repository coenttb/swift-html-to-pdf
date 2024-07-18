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
        
        let renderer = PrintPageRenderer(
            header: .test,
            footer: .pageNumbers
        )
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: self.html)

        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let paperRect = CGRect(origin: .zero, size: configuration.paperSize)

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

public struct Header: Sendable {
    let drawHeaderForPage: @MainActor @Sendable (_ renderer: PrintPageRenderer, _ pageIndex: Int, _ headerRect: CGRect) -> Void
    
    public static let test: Header = .init { renderer, pageIndex, headerRect in
        let headerText = "test"
        
        renderer.headerHeight = 300
        
        // Set up the attributes for the header text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.lightGray
        ]
        
        let textSize = (headerText as NSString).size(withAttributes: textAttributes)

        (headerText as NSString).draw(
            at: CGPoint(
                x: headerRect.midX - textSize.width / 2,
                y: headerRect.midY - textSize.height / 2
            ),
            withAttributes: textAttributes
        )
    }
    
}

public struct Footer: Sendable {
    let drawFooterForPage: @MainActor @Sendable (_ renderer: PrintPageRenderer, _ pageIndex: Int, _ footerRect: CGRect) -> Void
    
    public static let pageNumbers: Footer = .init { renderer, pageIndex, footerRect in
        
        renderer.footerHeight = 300
        
        let footerText = "\(pageIndex + 1) - \(renderer.numberOfPages)"
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.lightGray
        ]
        
        let textSize = (footerText as NSString).size(withAttributes: textAttributes)
        
        (footerText as NSString).draw(
            at: CGPoint(
                x: footerRect.midX - textSize.width / 2,
                y: footerRect.midY - textSize.height / 2
            ),
            withAttributes: textAttributes
        )
    }
}

class PrintPageRenderer: UIPrintPageRenderer {

    var header: Header?
    var footer: Footer?
    
    
    init(
        header: Header? = nil,
        footer: Footer? = nil
    ) {
        self.header = header
        self.footer = footer
        
        super.init()
        self.footerHeight = footer != nil ? 1 : 0
        self.headerHeight = header != nil ? 1 : 0
    }
    
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        self.header?.drawHeaderForPage(self, pageIndex, headerRect)
    }

    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
       
        self.footer?.drawFooterForPage(self, pageIndex, footerRect)
        
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
