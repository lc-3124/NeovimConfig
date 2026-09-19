# ============================================================================
# zsh 主配置（软链：~/.zshrc → NeovimConfig/zsh/.zshrc）
# ============================================================================

# ---- PATH：优先用户目录 ----
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ===== 密钥加载（私有文件，不提交到 git）=====
[[ -f ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh

# ===== Oh My Zsh =====
export ZSH="$HOME/.oh-my-zsh"
[[ -d "$ZSH" ]] || {
  echo "Oh My Zsh not found. Run: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
}

ZSH_THEME=""                # 使用自定义提示符，禁用 OMZ 主题

# ---- 短路径函数：把 $HOME 压缩为 ~，中间目录只取首字母 ----
prompt_short_path() {
    local full_path="${PWD/#$HOME/~}"
    [[ "$full_path" == "~" || "$full_path" == "/" ]] && echo "$full_path" && return
    local parts=(${(s:/:)full_path})
    local result=""
    for i in {1..${#parts[@]}}; do
        if [[ $i -eq 1 ]]; then
            result+="${parts[i]}"
        elif [[ $i -lt ${#parts[@]} ]]; then
            result+="/${parts[i][1]}"
        else
            result+="/${parts[i]}"
        fi
    done
    echo "$result"
}

# ===== 提示符 =====
PROMPT='%F{cyan}$(prompt_short_path)%f%F{yellow}>%f '    # 左提示：青色短路径 + 黄色 >
RPROMPT='%(?.%F{green}✓%f.%F{red}✗ %?%f)'                # 右提示：命令成功✓ / 失败✗+退出码

# ===== 匹配与更新 =====
CASE_SENSITIVE="true"           # 大小写敏感匹配
HYPHEN_INSENSITIVE="true"       # 连字符不敏感（foo-bar 可输 foobar）
zstyle ':omz:update' mode auto  # OMZ 自动更新

plugins=(git)                   # 启用 git 插件（别名/提示）

source $ZSH/oh-my-zsh.sh

# ===== 代理（FastLink，127.0.0.1:7890）=====
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export ftp_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890"
# 不走代理的地址（本机/局域网/内网）
export no_proxy="localhost,127.0.0.1,::1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.internal,*.intranet"
export NO_PROXY="$no_proxy"

# ===== 输入法（fcitx5）=====
export XMODIFIERS=@im=fcitx     # X11/XIM 输入法
export QT_IM_MODULE=fcitx       # Qt 应用输入法
export GTK_IM_MODULE=fcitx      # GTK 应用输入法

# ===== 终端 =====
export TERM=xterm-256color      # 256 色终端支持

# ===== Wine =====
export LANG=zh_CN.UTF-8         # 中文本地化

# ===== 模块加载：~/.config/zshrc.d/*.zsh 逐个 source =====
for f in ~/.config/zshrc.d/*.zsh(N); do source "$f"; done
# torrra: 取消 socks 代理避免其内置 httpx 报 ImportError
alias torrra="env -u all_proxy torrra"
