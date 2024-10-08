//
//  swift-html-to-pdf | shared.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

import Foundation

/// A model of a document that will be printed to a PDF.
///
/// ## Example
/// ```swift
/// let document = Document(
///     url: URL(...),
///     html: "..."
/// )
/// ```
///
/// - Parameters:
///   - url: The url at which to print the document.
///   - html: The String representing the HTML that will be printed.
///
public struct Document: Sendable {
    let fileUrl: URL
    let html: String
    
    public init(
        fileUrl: URL,
        html: String
    ) {
        self.fileUrl = fileUrl
        self.html = html
    }
}

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
    ///
    public func print(
        configuration: PDFConfiguration,
        createDirectories: Bool = true
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for document in self {
                taskGroup.addTask {
                    try await document.print(
                        configuration: configuration,
                        createDirectories: createDirectories
                    )
                }
                try await taskGroup.waitForAll()
            }
        }
    }
}

extension String {
    /// Prints a single html string to a PDF at the given URL, with the given margins.
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
    ///   - url: The url at which to print the PDF
    ///   - configuration: The configuration of the PDF document.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    ///
    @MainActor
    public func print(
        to fileUrl: URL,
        configuration: PDFConfiguration = .a4,
        createDirectories: Bool = true
    ) async throws {
        try await Document(fileUrl: fileUrl, html: self)
            .print(
                configuration: configuration,
                createDirectories: createDirectories
            )
    }
}

extension String {
    /// Prints a single html string to a PDF at the given directory with the title and margins.
    ///
    /// This function is more convenient when you have a directory and just want to title the PDF and save it to the directory.
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
    ///   - title: The title of the PDF
    ///   - directory: The directory at which to print the PDF
    ///   - configuration: The configuration of the PDF document.
    ///
    /// - Throws: `Error` if the function cannot clean up the temporary .html file it creates.
    public func print(
        title: String,
        to directory: URL,
        configuration: PDFConfiguration = .a4,
        createDirectories: Bool = true
    ) async throws {
        try await Document(
            fileUrl: directory.appendingPathComponent(title.replacingSlashesWithDivisionSlash()).appendingPathExtension("pdf"),
            html: self
        ).print(
            configuration: configuration,
            createDirectories: createDirectories
        )
    }
}

extension String {
    func replacingSlashesWithDivisionSlash() -> String {
        let divisionSlash = "\u{2215}" // Unicode for Division Slash (∕)
        return self.replacingOccurrences(of: "/", with: divisionSlash)
    }
}

extension Sequence<String> {
    /// Prints a collection of String to PDFs.
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
    ///   - directory: The directory at which to print the documents.
    ///   - configuration: The configuration that the PDFs will use.
    ///   - fileName: A closure that, given an Int that represents the index of the String in the collection, returns a fileName. Defaults to just the Index + 1.
    ///   - createDirectories: If true, the function will call FileManager.default.createDirectory for each document's directory.
    ///
    public func print(
        to directory: URL,
        configuration: PDFConfiguration = .a4,
        filename: (Int) -> String = { index in "\(index + 1)" },
        createDirectories: Bool = true
    ) async throws {
        try await self.enumerated()
            .map { (index, html) in
                Document(
                    fileUrl: directory
                        .appendingPathComponent(filename(index))
                        .appendingPathExtension("pdf"),
                    html: html
                )
            }
            .print(
                configuration: configuration,
                createDirectories: createDirectories
            )
    }
}

/// The configurations used to print to PDF
///
///
/// - Parameters:
///   - paperSize: The size of the paper, including margins.
///   - margins: The margins that are applied to each page of the PDF.
///   - baseURL: The base URL to use when the system resolves relative URLs within the HTML string of the PDF.
///
public struct PDFConfiguration: Sendable {
    let margins: EdgeInsets
    let paperSize: CGSize
    let baseURL: URL?
    let orientation: PDFConfiguration.Orientation
    
    //    public init(
    //        margins: EdgeInsets,
    //        paperSize: CGSize = .paperSize(),
    //        baseURL: URL? = nil
    //    ) {
    //        self.paperSize = paperSize
    //        self.margins = margins
    //        self.baseURL = baseURL
    //    }
    
    public init(
        margins: EdgeInsets,
        paperSize: CGSize = .paperSize(),
        baseURL: URL? = nil,
        orientation: PDFConfiguration.Orientation = .portrait
    ) {
        self.paperSize = paperSize
        self.margins = margins
        self.baseURL = baseURL
        self.orientation = orientation
    }
}

extension PDFConfiguration {
    
    public enum Orientation: Sendable {
        case landscape
        case portrait
    }
    
    public static var a4: PDFConfiguration {
        .a4(margins: .a4)
    }
    
    var printableRect: CGRect {
        .init(
            x: margins.left,
            y: margins.top,
            width: paperSize.width - margins.left - margins.right,
            height: paperSize.height - margins.top - margins.bottom
        )
    }
}

public struct EdgeInsets: Sendable {
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat
    
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

extension EdgeInsets {
    public static var a4: EdgeInsets {
        EdgeInsets(
            top: 36,
            left: 36,
            bottom: 36,
            right: 36
        )
    }
}

extension CGSize {
    public static func a4() -> CGSize {
        CGSize(width: 595.22, height: 841.85)
    }
}
