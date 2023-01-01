import Foundation

public struct CFIProxyModel: Decodable {
    
    public enum AdapterType: String, Decodable {
        
        case direct         = "Direct"
        case reject         = "Reject"
        case compatible     = "Compatible"
        case pass           = "Pass"
        
        case relay          = "Relay"
        case selector       = "Selector"
        case fallback       = "Fallback"
        case urlTest        = "URLTest"
        case loadBalance    = "LoadBalance"
        
        case shadowsocks    = "Shadowsocks"
        case shadowsocksR   = "ShadowsocksR"
        case snell          = "Snell"
        case socks5         = "Socks5"
        case http           = "Http"
        case vmess          = "Vmess"
        case vless          = "Vless"
        case trojan         = "Trojan"
        case hysteria       = "Hysteria"
        case wireGuard      = "WireGuard"
        case tuic           = "Tuic"
    }
    
    public struct Delay: Decodable {
        public let delay: UInt16
    }
    
    public let name: String
    public let type: AdapterType
    public let now: String
    public let all: [String]
    public let histories: [Delay]
    public let udp: Bool
    
    public enum CodingKeys: String, CodingKey {
        case name       = "name"
        case type       = "type"
        case now        = "now"
        case all        = "all"
        case histories  = "history"
        case udp        = "udp"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(AdapterType.self, forKey: .type)
        do {
            self.now = try container.decode(String.self, forKey: .now)
        } catch {
            self.now = ""
        }
        do {
            self.all = try container.decode([String].self, forKey: .all)
        } catch {
            self.all = []
        }
        self.histories = try container.decode([Delay].self, forKey: .histories)
        self.udp = try container.decode(Bool.self, forKey: .udp)
    }
}

extension CFIProxyModel.AdapterType {
    
    var isProviderType: Bool {
        switch self {
        case .relay, .selector, .fallback, .urlTest, .loadBalance:
            return true
        case .compatible, .pass, .direct, .reject, .shadowsocks, .shadowsocksR, .snell, .socks5, .http, .vmess, .trojan, .vless, .hysteria, .wireGuard, .tuic:
            return false
        }
    }
    
    var isProxyType: Bool {
        switch self {
        case .compatible, .pass, .relay, .selector, .fallback, .urlTest, .loadBalance, .direct, .reject:
            return false
        case .shadowsocks, .shadowsocksR, .snell, .socks5, .http, .vmess, .trojan, .vless, .hysteria, .wireGuard, .tuic:
            return true
        }
    }
}

extension CFIProxyModel.AdapterType {
    
    var name: String {
        switch self {
        case .direct:           return "DIRECT"
        case .reject:           return "REJECT"
        case .compatible:       return "COMPATIBLE"
        case .pass:             return "PASS"
        case .shadowsocks:      return "SHADOWSOCKS"
        case .shadowsocksR:     return "SHADOWSOCKSR"
        case .snell:            return "SNALL"
        case .socks5:           return "SOCKS5"
        case .http:             return "HTTP"
        case .vmess:            return "VMESS"
        case .trojan:           return "TROJAN"
        case .vless:            return "VLESS"
        case .hysteria:         return "HYSTERIA"
        case .wireGuard:        return "WIREGUARD"
        case .tuic:             return "TUIC"
        case .relay:            return "RELAY"
        case .selector:         return "SELECTOR"
        case .fallback:         return "FALLBACK"
        case .urlTest:          return "URL-TEST"
        case .loadBalance:      return "LOAD-BALANCE"
        }
    }
}
