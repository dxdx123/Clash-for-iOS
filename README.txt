系统要求：iOS16.0+

开发语言：Swift、Golang、C、Assembly

界面框架：SwiftUI、UIKit

内核：
    clash: https://github.com/Dreamacro/clash(1.13.0)
    xray: https://github.com/XTLS/Xray-core(1.7.5)

TUN实现(clash)：gvisor
    参考项目：
        https://github.com/WireGuard/wireguard-apple
        https://github.com/yaling888/clash

Tun2Socks(xray)：lwip
    https://github.com/heiher/hev-socks5-tunnel
    
编译：
    1.下载工程
    2.更新依赖
    3.修改Config.xcconfig中DEVELOPMENT_TEAM & APP_ID
  
关联项目：
    ClashKit：https://github.com/daemonomead/ClashKit
    Tun2SocksKit：https://github.com/daemooon/Tun2SocksKit
