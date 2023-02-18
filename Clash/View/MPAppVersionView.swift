import SwiftUI

struct MPAppVersionView: View {
    
    var body: some View {
        Text(version)
            .foregroundColor(.secondary)
            .font(.caption)
            .fontWeight(.light)
            .monospacedDigit()
    }
    
    private var version: String {
        guard let info = Bundle.main.infoDictionary,
              let version = info["CFBundleShortVersionString"] as? String else {
            return "--"
        }
        return "版本: \(version)"
    }
}

