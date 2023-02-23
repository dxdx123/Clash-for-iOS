import Foundation

extension MGConstant {
    @frozen public enum Clash {}
}

extension MGConstant.Clash {
    
    public static let tunnelMode            = "CLASH_TUNNEL_MODE"
    public static let logLevel              = "CLASH_LOGLEVEL"
    public static let extendAttributeKey    = "CLASH"
    public static let fileAttributeKey      = "NSFileExtendedAttributes"
    public static let trafficUp             = "CLASH_TRAFFIC_UP"
    public static let trafficDown           = "CLASH_TRAFFIC_DOWN"
    public static let ipv6Enable            = "CLASH_IPV6_ENABLE"
}

extension FileAttributeKey {
    public static let extended = FileAttributeKey(rawValue: MGConstant.Clash.fileAttributeKey)
}
