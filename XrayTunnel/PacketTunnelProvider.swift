import NetworkExtension
import XrayKit

@_silgen_name("start_tun2socks") private func tun2socks(_ config: UnsafePointer<CChar>!)

@frozen enum Tun2Socks {
    
    private static var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
    static func run(port: Int) {
        guard let fd = tunnelFileDescriptor else {
            fatalError("Get tunnel file descriptor failed.")
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let config: String = """
            [General]
            always-real-ip = *
            tun-fd = \(fd)

            [Proxy]
            XRAY = socks, 127.0.0.1, \(port)

            [Rule]
            FINAL, XRAY
            """
            tun2socks(config.cString(using: .utf8))
        }
    }
}


class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 1500
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: ["114.114.114.114"])
        try await self.setTunnelNetworkSettings(settings)
        do {
            var error: NSError? = nil
            let json: String = """
            {
                "log": {
                    "loglevel": "debug"
                },
                "routing": {
                    "domainStrategy": "IPIfNonMatch",
                    "rules": [
                        {
                            "type": "field",
                            "domain": [
                                "geosite:category-ads-all"
                            ],
                            "outboundTag": "block"
                        },
                        {
                            "type": "field",
                            "domain": [
                                "geosite:category-games@cn"
                            ],
                            "outboundTag": "direct"
                        },
                        {
                            "type": "field",
                            "domain": [
                                "geosite:geolocation-!cn"
                            ],
                            "outboundTag": "proxy"
                        },
                        {
                            "type": "field",
                            "domain": [
                                "geosite:cn",
                                "geosite:private"
                            ],
                            "outboundTag": "direct"
                        },
                        {
                            "type": "field",
                            "ip": [
                                "geoip:cn",
                                "geoip:private"
                            ],
                            "outboundTag": "direct"
                        }
                    ]
                },
                "inbounds": [
                    {
                        "listen": "127.0.0.1",
                        "port": 9090,
                        "protocol": "socks",
                        "settings": {
                            "udp": true
                        },
                        "sniffing": {
                            "enabled": true,
                            "destOverride": [
                                "http",
                                "tls"
                            ]
                        }
                    }
                ],
                "outbounds": [
                    {
                        "protocol": "vless",
                        "settings": {
                            "vnext": [
                                {
                                    "address": "www.arror.org",
                                    "port": 443,
                                    "users": [
                                        {
                                            "id": "0c83e70f-9f49-40dc-b05b-0c45fb0a12c6",
                                            "encryption": "none",
                                            "flow": "xtls-rprx-vision"
                                        }
                                    ]
                                }
                            ]
                        },
                        "streamSettings": {
                            "network": "tcp",
                            "security": "tls",
                            "tlsSettings": {
                                "serverName": "www.arror.org",
                                "allowInsecure": false,
                                "fingerprint": "chrome"
                            }
                        },
                        "tag": "proxy"
                    },
                    {
                        "protocol": "freedom",
                        "tag": "direct"
                    },
                    {
                        "protocol": "blackhole",
                        "tag": "block"
                    }
                ]
            }
            """
            XrayRun(json, self, &error)
            try error.flatMap { throw $0 }
            DispatchQueue.main.async {
                Tun2Socks.run(port: 9090)
            }
        } catch {
            NSLog("--------> \(error.localizedDescription)")
            throw error
        }
    }
    
    private var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason) async {
        
    }
    
    override func handleAppMessage(_ messageData: Data) async -> Data? {
        return nil
    }
}

extension PacketTunnelProvider: XrayLoggerProtocol {
    
    func onLog(_ msg: String?) {
        msg.flatMap { NSLog($0) }
    }
}
