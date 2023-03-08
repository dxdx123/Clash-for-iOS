import NetworkExtension
import XrayKit

class PacketTunnelProvider: MGPacketTunnelProvider, XrayLoggerProtocol {
        
    private var logLevel: MGLogLevel {
        MGLogLevel(rawValue: UserDefaults.shared.string(forKey: MGConstant.logLevel) ?? "") ?? .silent
    }
    
    override func onTunnelStartCompleted(with settings: NEPacketTunnelNetworkSettings) async throws {
        guard let id = UserDefaults.shared.string(forKey: "\(MGKernel.xray.rawValue.uppercased())_CURRENT"), !id.isEmpty else {
            fatalError()
        }
        XraySetAsset(MGKernel.xray.assetDirectory.path(percentEncoded: false), nil)
        let port = XrayGetAvailablePort()
        let base = """
        {
            "log": {
                "loglevel": "debug"
            },
            "inbounds": [
                {
                    "listen": "[::1]",
                    "protocol": "socks",
                    "settings": {
                        "udp": true,
                        "auth": "noauth"
                    },
                    "tag": "socks-in",
                    "port": \(port)
                }
            ],
            "outbounds": [
                {
                    "protocol": "freedom",
                    "tag": "direct"
                }
            ]
        }
        """
        var error: NSError? = nil
        XrayRun(
            base,
            MGKernel.xray.configDirectory.appending(component: "\(id).json").path(percentEncoded: false),
            self,
            &error
        )
        try error.flatMap { throw $0 }
        try Tunnel.start(port: port)
    }
    
    func onAccessLog(_ message: String?) {
        message.flatMap { NSLog($0) }
    }
    
    func onDNSLog(_ message: String?) {
        message.flatMap { NSLog($0) }
    }
    
    func onGeneralMessage(_ severity: String?, p1 message: String?) {
        message.flatMap { NSLog($0) }
    }
}


import os

public final class MangoLogger {
    
    private let logger: Logger
    
    public init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.hijack(fileDescriptor: FileHandle.standardOutput.fileDescriptor)
        self.hijack(fileDescriptor: FileHandle.standardError.fileDescriptor)
    }
    
    public func log(_ message: String) {
        self.logger.log("\(message, privacy: .public)")
    }
    
    private func hijack(fileDescriptor: Int32) {
        var rw = Array<Int32>(repeating: 0, count: 2)
        setbuf(fdopen(fileDescriptor, "w"), nil)
        pipe(&rw)
        dup2(rw[1], fileDescriptor)
        let fileHandle = FileHandle(fileDescriptor: rw[0])
        fileHandle.waitForDataInBackgroundAndNotify()
        fileHandle.readabilityHandler = { handler in
            let data = handler.availableData
            guard !data.isEmpty, let string = String(data: data, encoding: .utf8) else {
                return
            }
            string.components(separatedBy: CharacterSet(arrayLiteral: "\n")).forEach { value in
                guard !value.isEmpty else {
                    return
                }
                self.log(value)
            }
        }
    }
}
