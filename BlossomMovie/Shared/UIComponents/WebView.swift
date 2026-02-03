//
//  WebView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false

        // Load YouTube videos using HTML iframe embed
        if url.absoluteString.contains("youtube.com/embed") || url.absoluteString.contains("youtu.be") {
            // Sanitize URL by ensuring it's a valid YouTube embed URL
            guard let sanitizedURL = sanitizeYouTubeURL(url) else {
                // Fallback to direct loading if URL validation fails
                webView.load(URLRequest(url: url))
                return webView
            }

            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    * { margin: 0; padding: 0; }
                    html, body { height: 100%; width: 100%; overflow: hidden; }
                    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
                </style>
            </head>
            <body>
                <iframe src="\(sanitizedURL)"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                </iframe>
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: url)
        } else {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    // MARK: - Security
    private func sanitizeYouTubeURL(_ url: URL) -> String? {
        // Validate that the URL is from youtube.com or youtu.be
        guard let host = url.host?.lowercased(),
              host.contains("youtube.com") || host.contains("youtu.be") else {
            return nil
        }

        // Return the absolute string which is already validated
        return url.absoluteString
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update if needed
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // Could add loading indicator here
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Navigation finished successfully
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // Handle navigation error
            print("WebView navigation failed: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            // Handle provisional navigation error
            print("WebView provisional navigation failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    WebView(url: URL(string: "https://www.apple.com")!)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
}
