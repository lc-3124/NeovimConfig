# Just A Neovim Config File , Used To Sync On My PCs
- Plugins by Plug
- Need sshkey to clone project
- My own Keyblinds ,no for any one else

# Just Look Like This :
 
```
 1 s/U/VaTerm.cpp                                                                                                                                                  buffers
                         │   28     if (tcgetattr(fd: STDIN_FILENO, termios_p: &currentAttrs) != 0) {                                         │" Press <F1>, ? for help
  </clonework/VA-Utils/  │   29     ¦   throw std::runtime_error("Failed to get terminal attributes.");                                       │
  - build/               │   30     }                                                                                                         │▾ variables
      all*               │   31 }                                                                                                             │    currentAttrs
      ColorAndEffectOutpu│   32                                                                                                               │    originalAttrs
      Cursor*            │   33 // 保存终端原始设置                                                                                           │
      getUtfChar*        │   34 void VaTui::Term::SaveTerm() {                                                                                │▾ VaTui* : unknown
      mapUtfCh*          │   35     getTerminalAttrsSafely();                                                                                 │  ▾ Term* : class
      sysinfo*           │   36     originalAttrs = currentAttrs;                                                                             │    ¦ [functions]
  - obj/                 │   37 }                                                                                                             │    ¦ Clear()
      VaColor.o          │   38                                                                                                               │    ¦ ClearLine()
      VaCusor.o          │   39 // 恢复终端原始设置                                                                                           │    ¦ RestoreTerm()
      VaPinyin.o         │   40 void VaTui::Term::RestoreTerm() {                                                                             │    ¦ SaveTerm()
      VaPinyin2.o        │   41     setTerminalAttrsSafely(newAttrs: originalAttrs);                                                          │    ¦ _Clear()
      VaSystem.o         │   42     // system("reset");                                                                                       │    ¦ _ClearLine()
      VaTerm.o           │   43 }                                                                                                             │    ¦ disableConsoleBuffering(
      VaUtf.o            │   44                                                                                                               │    ¦ disableEcho()
  - [✗]src/Unix/         │   45 // 清空整个屏幕                                                                                               │    ¦ enableConsoleBuffering()
      VaColor.cpp        │   46 const char *VaTui::Term::_Clear() { return "\033[2J"; }                                                       │    ¦ enableEcho()
      VaCusor.cpp        │   47 void VaTui::Term::Clear() { fastOutput(str: "\033[2J"); }                                                     │    ¦ fastOutput(const char *
      [✚]VaPinyin.cpp    │   48                                                                                                               │    ¦ getCharacter()
      VaPinyin2.cpp      │   49 // 清空从光标位置到行尾的区域                                                                                 │    ¦ getInputSpeed()
      VaSystem.cpp       │   50 const char *VaTui::Term::_ClearLine() { return "\033[K"; }                                                    │    ¦ getTerminalAttributes()
      [✹]VaTerm.cpp      │   51 void VaTui::Term::ClearLine() { fastOutput(str: "\033[K"); }                                                  │    ¦ getTerminalAttrsSafely()
      VaUtf.cpp          │   52                                                                                                               │    ¦ getTerminalSize(int & ro
  - [✗]test/             │   53 // 获取终端属性                                                                                               │    ¦ getTerminalType()
    + [✭]tui1_hpp/       │   54 void VaTui::Term::getTerminalAttributes() { getTerminalAttrsSafely(); }                                       │    ¦ getkeyPressed(char & k)
      [✹]all.cpp         │   55                                                                                                               │    ¦ isTerminalFeatureSupport
      ColorAndEffectOutpu│   56 // 设置终端属性                                                                                               │    ¦ nonBufferedGetKey()
      Cursor.cpp         │   57 void VaTui::Term::setTerminalAttributes(const termios &newAttrs) {                                            │    ¦ restoreCursorPosition()
      getUtfChar.cpp     │   58     setTerminalAttrsSafely(newAttrs);                                                                         │    ¦ saveCursorPosition()
      mapUtfCh.cpp       │   59 }                                                                                                             │    ¦ setCharacterDelay(int mi
      [✹]sysinfo.cpp     │   60                                                                                                               │    ¦ setCursorPosition(int ro
      [✭]tui1.cpp        │   61 // 启用终端回显                                                                                               │    ¦ setCursorShape(CursorSha
    compile_commands.json│   62 void VaTui::Term::enableEcho() {                                                                              │    ¦ setInputSpeed(int speed)
    LICENSE              │   63     termios newAttrs = currentAttrs;                                                                          │    ¦ setLineBuffering(bool en
    Makefile             │   64     newAttrs.c_lflag |= ECHO;                                                                                 │    ¦ setOutputSpeed(int speed
    README.md            │   65     setTerminalAttrsSafely(newAttrs);                                                                         │    ¦ setTerminalAttributes(co

     1 ➜ AirlineSelectTab1           5 ➜ AirlineSelectTab5           9 ➜ AirlineSelectTab9           a ➜ +coc-codeaction-selected)   r ➜ +1 keymap
     2 ➜ AirlineSelectTab2           6 ➜ AirlineSelectTab6           F ➜ Format 0gg10000000==        c ➜ +5 keymaps
     3 ➜ AirlineSelectTab3           7 ➜ AirlineSelectTab7           + ➜ AirlineSelectNextTab        f ➜ +coc-format-selected)
     4 ➜ AirlineSelectTab4           8 ➜ AirlineSelectTab8           - ➜ AirlineSelectPrevTab        q ➜ +bp:bd #

  \                                                                           󱊷  close  󰁮 back
<24/clonework/VA-Utils   NORMAL  src/Unix/VaTerm.cpp                   getTerminalAttrsSafely()  cpp  utf-8[unix]  12% :31/242 ℅:1   Tagbar  Name  VaTerm.cpp
"src/Unix/VaTerm.cpp" 242 lines --12%--
```
