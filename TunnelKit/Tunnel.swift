import Foundation

@_silgen_name("hev_socks5_tunnel_main")
private func hev_socks5_tunnel_main( _ configFilePath: UnsafePointer<CChar>!, _ fd: Int32)

public enum Tunnel {
    
    private static var tunnelFileDescriptor: Int32? {
        var buf = Array<CChar>(repeating: 0, count: Int(IFNAMSIZ))
        return (1...1024).first {
            var len = socklen_t(buf.count)
            return getsockopt($0, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun")
        }
    }
    
    public static func start(port: Int) throws {
        let config = """
        tunnel:
          mtu: 9000
          ipv4:
            address: 198.18.0.1
            gateway: 198.18.0.1
            prefix: 16

        socks5:
          port: \(port)
          address: ::1
          udp: 'udp'

        misc:
          task-stack-size: 20480
          connect-timeout: 5000
          read-write-timeout: 60000
          log-file: stderr
          log-level: debug
          limit-nofile: 65535
        """
        let cache = URL(filePath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0], directoryHint: .isDirectory)
        let file = cache.appending(component: "\(UUID().uuidString).yml", directoryHint: .notDirectory)
        try config.write(to: file, atomically: true, encoding: .utf8)
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fd = self.tunnelFileDescriptor else {
                fatalError()
            }
            hev_socks5_tunnel_main(file.path(percentEncoded: false), fd)
        }
    }
}
