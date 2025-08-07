return {
    "octol/vim-cpp-enhanced-highlight",
    ft = { "cpp", "c", "objc", "objcpp" }, -- 仅对 C/C++ 文件加载
    init = function()
      -- 启用插件的高阶特性
      vim.g.cpp_class_scope_highlight = 1      -- 高亮类作用域
      vim.g.cpp_member_variable_highlight = 1  -- 高亮成员变量
      vim.g.cpp_experimental_template_highlight = 1 -- 改进模板高亮
    end
}
