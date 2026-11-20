import Foundation
import SwiftUI
import UIKit

/// A file the person asked to export. Identifiable so it can drive `.sheet(item:)`.
struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
}

/// Thin wrapper around the system share sheet.
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
