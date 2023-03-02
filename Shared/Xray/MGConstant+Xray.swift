import Foundation

extension MGConstant {
    @frozen public enum Xray {}
}

extension MGConstant.Xray {
    
    public static let sniffingEnable                = "XRAY_SNIFFING_ENABLE"
    public static let sniffingDestOverrideHTTP      = "XRAY_SNIFFING_DEST_OVERRIDE_HTTP"
    public static let sniffingDestOverrideTLS       = "XRAY_SNIFFING_DEST_OVERRIDE_TLS"
    public static let sniffingDestOverrideQUIC      = "XRAY_SNIFFING_DEST_OVERRIDE_QUIC"
    public static let sniffingDestOverrideFAKEDNS   = "XRAY_SNIFFING_DEST_OVERRIDE_FAKEDNS"
}
