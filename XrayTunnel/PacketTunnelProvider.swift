import NetworkExtension
import XrayKit

//@_silgen_name("start_tun2socks") private func tun2socks(_ fd: Int32, _ config: UnsafePointer<CChar>!)

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 9000
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "114.114.114.114"])
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
                        "listen": "[::1]",
                        "port": 7890,
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
//            DispatchQueue.global(qos: .userInitiated).async {
//                guard let fd = self.tunnelFileDescriptor else {
//                    fatalError()
//                }
//                guard let file = Bundle.main.path(forResource: "main", ofType: "yml") else {
//                    fatalError()
//                }
//                tun2socks(fd, file)
//            }
        } catch {
            NSLog("--------> \(error.localizedDescription)")
            throw error
        }
    }
    
//    override func stopTunnel(with reason: NEProviderStopReason) async {
//
//    }
//
//    override func handleAppMessage(_ messageData: Data) async -> Data? {
//        return nil
//    }
}

extension PacketTunnelProvider: XrayLoggerProtocol {

    func onLog(_ msg: String?) {
        msg.flatMap { NSLog($0) }
    }
}
