# 音频配置（WirePlumber + 蓝牙）

## 概览

| 项目 | 内容 |
|------|------|
| 音频服务 | PipeWire + WirePlumber 会话管理 |
| 配置方式 | WirePlumber drop-in 文件 |
| 配置文件 | `wireplumber/51-bluetooth-buffer.conf` |
| 目标路径 | `~/.config/wireplumber/wireplumber.conf.d/` |

## 蓝牙音频

### 问题

蓝牙耳机/音箱连接后声音像"沉水说话"——这是 HSP/HFP（免提通话模式）的特征，使用 CVSD 编码 8kHz 单声道，音质极差。

### 解决方案

强制使用 A2DP（高级音频分发配置）高保真模式。

```lua
wireplumber.settings = {
  bluetooth.autoswitch-to-headset-profile = false   -- 禁止自动切回通话模式
}

monitor.bluez.properties = {
  bluez5.codecs = [ sbc_xq ldac aptx_hd aptx aac sbc ]  -- 优先高品质编码
  bluez5.enable-sbc-xq = true                             -- 启用 SBC XQ
  bluez5.default.rate = 48000                              -- 48kHz 采样率
  bluez5.default.channels = 2                              -- 立体声
}

monitor.bluez.rules = [
  {
    matches = [ { device.name = "~bluez_card.*" } ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink ]        -- 只连接 A2DP 配置
      }
    }
  }
  {
    matches = [ { node.name = "~bluez_output.*" } ]
    actions = {
      update-props = {
        node.latency = "1024/48000"                -- 21ms 缓冲，平衡延迟与稳定
      }
    }
  }
]
```

### 手动切换配置

如果某设备仍跑在通话模式，可以手动切换：

```bash
# 查看当前活动配置
pactl list cards | grep -E "Name:|Active Profile|codec"

# 切换到 A2DP SBC XQ
pactl set-card-profile bluez_card.XX_XX_XX_XX_XX_XX a2dp-sink-sbc_xq

# 切换回通话模式（需要麦克风时）
pactl set-card-profile bluez_card.XX_XX_XX_XX_XX_XX headset-head-unit
```

### 重新连接设备使配置生效

```bash
bluetoothctl disconnect XX:XX:XX:XX:XX:XX
bluetoothctl connect   XX:XX:XX:XX:XX:XX
```

### 重启 WirePlumber

```bash
systemctl --user restart wireplumber
```

## 依赖

- `pipewire` — 音频服务
- `wireplumber` — 会话管理器
- `pipewire-pulse` — PulseAudio 兼容层
