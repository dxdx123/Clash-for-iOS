import Foundation
import Tun2SocksKit

public enum Tunnel {
    
    public static func start(port: Int) throws {
        let config = """
        tunnel:
          mtu: 9000
        
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
            DispatchQueue.global(qos: .userInitiated).async {
                NSLog("HEV_SOCKS5_TUNNEL_MAIN: \(Socks5Tunnel.run(withConfig: file.path(percentEncoded: false)))")
            }
        }
    }
}
