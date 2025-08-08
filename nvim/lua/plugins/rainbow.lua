return{
  {
    -- 暂时用这个，之后安装nvim treesitter
  "luochen1990/rainbow",
  lazy = false,
  init = function()
    vim.g.rainbow_active = 1
    -- 自定义颜色（Gruvbox 主题示例）
    vim.cmd([[
    hi rainbowcol1 guifg=#fb4934 ctermfg=167
    hi rainbowcol2 guifg=#b8bb26 ctermfg=142
    hi rainbowcol3 guifg=#83a598 ctermfg=109
    ]])
  end
}
}
