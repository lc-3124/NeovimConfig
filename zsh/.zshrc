export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ===== 密钥加载（私有文件，不提交到 git）=====
[[ -f ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh

# ===== Oh My Zsh =====
export ZSH="$HOME/.oh-my-zsh"
[[ -d "$ZSH" ]] || {
  echo "Oh My Zsh not found. Run: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
}

ZSH_THEME=""

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

PROMPT='%F{cyan}$(prompt_short_path)%f%F{yellow}>%f '
RPROMPT='%(?.%F{green}✓%f.%F{red}✗ %?%f)'

CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ===== 代理 =====
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export ftp_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890"
export no_proxy="localhost,127.0.0.1,::1,*.local"

# ===== 输入法 =====
export XMODIFIERS=@im=fcitx

# ===== 终端 =====
export TERM=xterm-256color

# ===== 模块加载 =====
for f in ~/.config/zshrc.d/*.zsh(N); do source "$f"; done
