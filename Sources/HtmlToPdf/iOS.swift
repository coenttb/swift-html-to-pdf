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
        configuration: PDFConfiguration = .a4
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
        configuration: PDFConfiguration = .a4,
        using webView: WKWebView = WKWebView(frame: .zero)
    ) async throws {
        let html = self

        let renderer = UIPrintPageRenderer.init()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: html)
        //    let printFormatter = UISimpleTextPrintFormatter(attributedText: attributedString)

        //    let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)

        // Use this to get US Letter size instead
        // let pageSize = CGSize(width: 612, height: 792)

        // create some sensible margins
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)

        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)

        // and here's the overall paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)

        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSRange(location: 0, length: renderer.numberOfPages))

        let bounds = UIGraphicsGetPDFContextBounds()

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: bounds)
        }

        UIGraphicsEndPDFContext()

        do {
            try pdfData.write(to: url)
        } catch {
            Swift.print(error.localizedDescription)
        }
    }
}

extension UIEdgeInsets {
    public static let a4: UIEdgeInsets = UIEdgeInsets(
        top: -36,
        left: -36,
        bottom: 36,
        right: 36
    )
}

extension PDFConfiguration {
    public static func a4(margins: EdgeInsets = .a4) -> PDFConfiguration {
//        
//        let pageWidth: CGFloat = 595.22
//        let pageHeight: CGFloat = 841.85
//        let printableWidth = pageWidth - margins.left - margins.right
//        let printableHeight = pageHeight - margins.top - margins.bottom
//        
//        let rect = CGRect(
//            x: margins.left,
//            y: margins.top,
//            width: printableWidth,
//            height: printableHeight
//        )
//        
        return .init(paperSize: .paperSize, margins: margins)
    }
}

extension CGSize {
    static let paperSize: CGSize = CGSize(width: 595.22, height: 841.85)
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
