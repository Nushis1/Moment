import Foundation

/// Localized, template-based wording. All text is written by hand; nothing is generated.
enum Msg {
    static func t(_ value: String.LocalizationValue) -> String {
        String(localized: value, bundle: .module)
    }
}

/// Stable hash so wording variants are chosen deterministically (Swift's own hashing is
/// randomized per launch).
enum StableHash {
    static func value(_ text: String) -> UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }

    static func pick(_ count: Int, seed: String) -> Int {
        guard count > 0 else { return 0 }
        return Int(value(seed) % UInt64(count))
    }
}
