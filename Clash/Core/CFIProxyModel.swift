import Foundation

public struct CFIProxyModel: Decodable {
    
    public enum AdapterType: String, Decodable {
        
        case direct         = "Direct"
        case reject         = "Reject"
        
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
        case trojan         = "Trojan"
        case wireGuard      = "WireGuard"
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
        case .direct, .reject, .shadowsocks, .shadowsocksR, .snell, .socks5, .http, .vmess, .trojan, .wireGuard:
            return false
        }
    }
    
    var isProxyType: Bool {
        switch self {
        case .relay, .selector, .fallback, .urlTest, .loadBalance, .direct, .reject:
            return false
        case .shadowsocks, .shadowsocksR, .snell, .socks5, .http, .vmess, .trojan, .wireGuard:
            return true
        }
    }
}

extension CFIProxyModel.AdapterType {
    
    var name: String {
        switch self {
        case .direct:           return "Direct"
        case .reject:           return "Reject"
        case .shadowsocks:      return "Shadowsocks"
        case .shadowsocksR:     return "ShadowsocksR"
        case .snell:            return "Snell"
        case .socks5:           return "Socks5"
        case .http:             return "HTTP"
        case .vmess:            return "Vmess"
        case .trojan:           return "Trojan"
        case .wireGuard:        return "WIREGUARD"
        case .relay:            return "Relay"
        case .selector:         return "Selector"
        case .fallback:         return "Fallback"
        case .urlTest:          return "URL Test"
        case .loadBalance:      return "Load Balance"
        }
    }
}
