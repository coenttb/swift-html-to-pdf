//
//  File.swift
//  swift-html-to-pdf
//
//  Created by Coen ten Thije Boonkkamp on 08/09/2024.
//

#if canImport(WebKit)
import Foundation
import WebKit

@MainActor
class WebViewPool {
    private var pool: [WKWebView]
    private let semaphore: DispatchSemaphore

    private init(size: Int) {
        self.pool = (0..<size).map { _ in
            WKWebView(frame: .zero)
        }
        self.semaphore = DispatchSemaphore(value: size)
    }

    func acquire() -> WKWebView? {
        semaphore.wait()
        return pool.isEmpty ? nil : pool.removeFirst()
    }

    func acquireWithRetry(retries: Int = 8, delay: TimeInterval = 0.2) async throws -> WKWebView {
        for _ in 0..<retries {
            if let webView = self.acquire() {
                return webView
            }
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        throw WebViewPool.Error.timeout
    }

    func release(_ webView: WKWebView) {
        defer { semaphore.signal() }
        pool.append(webView)
    }

    static let shared: WebViewPool = .init(size: ProcessInfo.processInfo.activeProcessorCount)
}

extension WebViewPool {
    enum Error: Swift.Error {
        case timeout
    }
}

#endif
