#!/bin/bash
# ============================================================================
# 熄屏切换脚本 —— META+ALT+K
# 功能：关闭显示器（DPMS off，系统保持运行），再次按 META+ALT+K 恢复显示。
# 用 wlopm（wlr-output-power-management 协议）读取/切换，状态可靠。
#   wlopm 输出 "eDP-1 on/off"，grep 到 " on$" 表示当前亮着
# ============================================================================

if wlopm 2>/dev/null | grep -q ' on$'; then
    # 当前亮着 → 熄屏
    wlopm --off '*' >/dev/null 2>&1
else
    # 当前熄屏 → 唤醒
    wlopm --on '*' >/dev/null 2>&1
fi
