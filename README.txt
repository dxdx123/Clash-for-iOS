系统要求：iOS16.0+

开发语言：Swift、Golang、C

界面框架：SwiftUI、UIKit

内核：https://github.com/Dreamacro/clash

TUN实现：LwIP & System混合
  参考项目：
    https://github.com/WireGuard/wireguard-apple
    TCP（LwIP）：
      - https://github.com/eycorsican/go-tun2socks
      - https://github.com/SagerNet/sing-tun
    UDP（System）：
      - https://github.com/MetaCubeX/Clash.Meta
      - https://github.com/yaling888/clash
      - https://github.com/SagerNet/sing-tun

编译：
  1.下载工程
  2.更新依赖
  3.修改Config.xcconfig中DEVELOPMENT_TEAM & APP_ID
  
关联项目：
  ClashKit：https://github.com/daemonomead/ClashKit
  Tun2SocksKit：https://github.com/daemonomead/Tun2SocksKit
