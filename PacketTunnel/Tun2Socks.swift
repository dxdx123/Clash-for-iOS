import Foundation

@_silgen_name("run") private func rust_run(_ config: UnsafePointer<CChar>!)

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
            {
                "log": {
                    "level": "debug"
                },
                "inbounds": [
                    {
                        "protocol": "tun",
                        "settings": {
                            "fd": \(fd)
                        },
                        "tag": "tun"
                    }
                ],
                "outbounds": [
                    {
                        "protocol": "socks",
                        "settings": {
                            "address": "127.0.0.1",
                            "port": \(port)
                        },
                        "tag": "clash"
                    }
                ]
            }
            """
            rust_run(config.cString(using: .utf8))
        }
    }
}
