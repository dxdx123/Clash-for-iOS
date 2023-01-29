import Foundation
import SwiftUI

private class CFITrafficFormatter: NumberFormatter {
    
    static let `default` = CFITrafficFormatter()
    
    override init() {
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable)
    public override func number(from string: String) -> NSNumber? {
        fatalError("number(from:) has not been implemented")
    }
    
    override func string(from number: NSNumber) -> String? {
        let kb = number.int64Value / 1024
        guard kb >= 1024 else {
            return "\(kb)KB"
        }
        let mb = number.doubleValue / 1024.0 / 1024.0
        if mb >= 1000 {
            return String(format: "%.1fGB", mb / 1024.0)
        } else if mb >= 100 {
            return String(format: "%.1fMB", mb)
        } else {
            return String(format: "%.2fMB", mb)
        }
    }
}

enum ClashTrafficFormatterKey: EnvironmentKey {
    static let defaultValue: NumberFormatter = CFITrafficFormatter.default
}

extension EnvironmentValues {
    
    public var trafficFormatter: NumberFormatter {
        get { self[ClashTrafficFormatterKey.self] }
        set { self[ClashTrafficFormatterKey.self] = newValue }
    }
}

