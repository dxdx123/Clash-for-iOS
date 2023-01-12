import Foundation

@_silgen_name("start_tun2socks") private func startTun2socks(_ config: UnsafePointer<CChar>!)

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
        
        let config: String = """
        [General]
        loglevel = debug
        dns-server = 127.0.0.1
        always-real-ip = *
        tun-fd = \(fd)

        [Proxy]
        clash = socks, 127.0.0.1, \(port)
        clash-dns = redirect, 127.0.0.1, 53

        [Rule]
        PORT-RANGE, 53-53, clash-dns
        FINAL, clash
        """
        DispatchQueue.global(qos: .userInitiated).async {
            startTun2socks(config.cString(using: .utf8))
        }
    }
}
