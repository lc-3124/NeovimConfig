# ===== 历史导航仅限当前终端 =====
# OMZ 默认 share_history：所有终端的命令按时间实时合并，
# 上箭头会翻出其他终端输入的命令。
unsetopt SHARE_HISTORY        # 关闭跨终端共享，本终端只回溯自己输入的内容
setopt INC_APPEND_HISTORY     # 命令仍即时写入 HISTFILE（防崩溃丢失），
                              # 但不会进入其他会话的上箭头导航
