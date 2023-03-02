import Foundation

extension MGConstant {
    @frozen public enum Clash {}
}

extension MGConstant.Clash {
    
    public static let tunnelMode            = "CLASH_TUNNEL_MODE"
    public static let extendAttributeKey    = "CLASH"
    public static let fileAttributeKey      = "NSFileExtendedAttributes"
    public static let trafficUp             = "CLASH_TRAFFIC_UP"
    public static let trafficDown           = "CLASH_TRAFFIC_DOWN"
}

extension FileAttributeKey {
    public static let extended = FileAttributeKey(rawValue: MGConstant.Clash.fileAttributeKey)
}
