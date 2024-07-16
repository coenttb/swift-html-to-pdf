//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

#if os(macOS)
import Foundation
import WebKit

extension String {
    /// Prints a single html string to a pdf at the given directory with the title and margins.
    ///
    /// This function is more convenient when you have a directory and just want to title the pdf and save it to the directory.
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
    ///   - configuration: The configuration of the pdf document.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    public func print(
        title: String,
        to directory: URL,
        configuration: PDFConfiguration = .a4
    ) async throws {
        try await self.print(
            to: directory.appendingPathComponent(title, conformingTo: .pdf),
            configuration: configuration
        )
    }
}

extension CGRect {
    static func paperSize()-> CGRect {
        CGRect(x: 0, y: 0, width: NSPrintInfo.shared.paperSize.width, height: NSPrintInfo.shared.paperSize.height)
    }
    static func a4() -> CGRect {
        CGRect(x: 0, y: 0, width: 595.22, height: 841.85)
    }
}

public extension NSPrintInfo {
    static func pdf(url: URL) -> NSPrintInfo {
        NSPrintInfo(
            dictionary: [
                .jobDisposition: NSPrintInfo.JobDisposition.save,
                .jobSavingURL: url,
                .allPages: true,
                .topMargin: 0.0,
                .bottomMargin: 0.0,
                .leftMargin: 0.0,
                .rightMargin: 0.0,
                .paperSize: NSSize(width: 595.22, height: 841.85)
                    
            ]
        )
    }
}




extension String {
    /// Prints a single html string to a pdf at the given URL, with the given margins.
    ///
    /// ## Example
    /// ```swift
    /// let html = "<html><body><h1>Hello, World!</h1></body></html>"
    /// let url = URL.downloadsDirectory
    ///     .appendingPathComponent("helloWorld", conformingTo: .pdf)
    /// try await html.print(to:url)
    /// ```
    ///
    /// - Parameters:
    ///   - url: The url at which to print the pdf
    ///   - configuration: The configuration of the pdf document.
    ///   - webView: In allmost all circumstances you can omit this parameter. the function will re-use webviews for performance reasons and you may optionally provide an already existing webView.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    ///
    @MainActor
    public func print(
        to url: URL,
        configuration: PDFConfiguration = .a4,
        using webView: WKWebView = WKWebView(frame: .zero)
    ) async throws {
        let window = NSWindow()
        
        
        let webViewNavigationDelegate = WebViewNavigationDelegate(
            window: window,
            outputURL: url,
            configuration: configuration
        )
        
        webView.navigationDelegate = webViewNavigationDelegate
        webView.loadHTMLString(self, baseURL: nil)
        
        await withCheckedContinuation { continuation in
            webViewNavigationDelegate.onFinished = {
                continuation.resume()
            }
        }
    }
}

extension NSEdgeInsets {
    public static let a4: NSEdgeInsets = NSEdgeInsets(
        top: -36,
        left: -36,
        bottom: -36,
        right: -36
    )
}

extension PDFConfiguration {
    public static func a4(margins: NSEdgeInsets = .a4) -> PDFConfiguration {
        return .init(paperSize: .paperSize(), margins: margins)
    }
}

#endif
