import Foundation

/// The boundary between the UI and MOMENT CORE.
///
/// Everything behind this protocol runs locally and deterministically. The app depends only
/// on this contract, so the engine can be swapped without touching any screen.
public protocol MomentAnalyzing: Sendable {
    func analyze(_ input: MomentInput) async throws -> MomentAnalysis
    func analyzeReply(_ input: ReplyInput) async throws -> ReplyAnalysis
}
