#!/usr/bin/env python3
# grab-pointers.py —— 用 EVIOCGRAB 抓取所有指针类 evdev 设备
#   （鼠标 / 触摸板 / 指点杆），使其事件不再到达 Hyprland：
#   光标不动、不悬停、不点击。以 root 运行；退出/被 kill 时自动释放。
import os, glob, fcntl, signal, sys, time

EVIOCGRAB = 0x40044590
KEYS = ("mouse", "touchpad", "trackpad", "trackpoint", "trackball")

def dev_name(ev):
    try:
        with open(f"/sys/class/input/{ev}/device/name") as f:
            return f.read().strip()
    except OSError:
        return ""

def is_pointer(name):
    n = name.lower()
    if "keyboard" in n:
        return False
    return any(k in n for k in KEYS)

held = {}

def grab_all():
    for syspath in sorted(glob.glob("/sys/class/input/event*")):
        ev = os.path.basename(syspath)
        node = f"/dev/input/{ev}"
        if node in held or not is_pointer(dev_name(ev)):
            continue
        try:
            fd = os.open(node, os.O_RDONLY | os.O_NONBLOCK)
            fcntl.ioctl(fd, EVIOCGRAB, 1)
        except OSError:
            try: os.close(fd)
            except Exception: pass
            continue
        held[node] = fd
        print(f"grab {node} ({dev_name(ev)})", flush=True)

def release(*_):
    for fd in held.values():
        try: fcntl.ioctl(fd, EVIOCGRAB, 0)
        except OSError: pass
        try: os.close(fd)
        except OSError: pass
    sys.exit(0)

signal.signal(signal.SIGTERM, release)
signal.signal(signal.SIGINT, release)
grab_all()
while True:
    time.sleep(3)
    grab_all()
