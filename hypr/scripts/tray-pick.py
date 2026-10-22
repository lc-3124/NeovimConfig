#!/usr/bin/env python3
# ============================================================================
# tray-pick.py —— 纯键盘操作系统托盘（StatusNotifierItem）
#
# 原理：托盘项通过 DBus 暴露：
#   org.kde.StatusNotifierWatcher  → 已注册项列表
#   org.kde.StatusNotifierItem     → Title / Id / Menu / Activate()
#   com.canonical.dbusmenu         → GetLayout() 读菜单树 / Event() 触发
# 这里用 fuzzel 做选择器，逐层展开菜单，不依赖鼠标坐标。
#
# 用法:
#   tray-pick.py            打开选择器
#   tray-pick.py --list     只列出托盘项（调试）
# ============================================================================
import sys
import subprocess

import dbus

WATCHER = ("org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher")
IFACE_WATCHER = "org.kde.StatusNotifierWatcher"
IFACE_SNI = "org.kde.StatusNotifierItem"
IFACE_MENU = "com.canonical.dbusmenu"

BUS = dbus.SessionBus()


def fuzzel(prompt, lines):
    """调用 fuzzel 选择一行；取消返回 None"""
    if not lines:
        return None
    p = subprocess.run(
        ["fuzzel", "--dmenu", "--prompt", prompt + " ",
         "--lines", str(min(len(lines), 20)), "--width", "60"],
        input="\n".join(lines), text=True, capture_output=True)
    if p.returncode != 0:
        return None
    return p.stdout.rstrip("\n")


def notify(msg):
    subprocess.run(["hyprctl", "notify", "2", "3000", "rgb(f9e2af)", msg],
                   capture_output=True)


def props(svc, path):
    return dbus.Interface(BUS.get_object(svc, path), "org.freedesktop.DBus.Properties")


def resolve_item(item):
    """watcher 里的格式可能是 'svc/path' 或只有 'svc'"""
    if "/" in item:
        svc, rest = item.split("/", 1)
        return svc, "/" + rest
    return item, "/StatusNotifierItem"


def list_items():
    out = []
    w = BUS.get_object(*WATCHER)
    for it in w.Get(IFACE_WATCHER, "RegisteredStatusNotifierItems",
                    dbus_interface="org.freedesktop.DBus.Properties"):
        svc, path = resolve_item(str(it))
        try:
            p = props(svc, path)
            title = str(p.Get(IFACE_SNI, "Title")) or str(p.Get(IFACE_SNI, "Id")) or svc
            ident = str(p.Get(IFACE_SNI, "Id"))
            menu = str(p.Get(IFACE_SNI, "Menu"))
        except Exception:
            continue
        out.append({"svc": svc, "path": path, "title": title, "id": ident, "menu": menu})
    return out


def menu_nodes(svc, menu_path, parent_id=0):
    """返回 [(id, label, enabled, has_children, depth)]，只取可见项"""
    m = dbus.Interface(BUS.get_object(svc, menu_path), IFACE_MENU)
    rev, root = m.GetLayout(dbus.Int32(parent_id), dbus.Int32(-1),
                            dbus.Array([], signature="s"))
    flat = []

    def walk(node, depth):
        nid, pr, children = int(node[0]), node[1], node[2]
        label = str(pr.get("label", "")).replace("_", "").strip()
        visible = bool(pr.get("visible", True))
        enabled = bool(pr.get("enabled", True))
        typ = str(pr.get("type", "standard"))
        # 跳过 parent 节点自身（GetLayout 会把根节点一起返回）
        if nid != parent_id and visible and typ != "separator" and label and label != " ":
            flat.append((nid, label, enabled, bool(len(children)), depth))
        child_depth = depth + 1 if nid != parent_id else depth
        for ch in children:
            walk(ch, child_depth)

    walk(root, 0)
    return flat


def menu_event(svc, menu_path, nid):
    m = dbus.Interface(BUS.get_object(svc, menu_path), IFACE_MENU)
    m.Event(dbus.Int32(nid), dbus.String("clicked"), dbus.String(""), dbus.UInt32(0))


def pick_menu(svc, menu_path, title):
    """逐层展开菜单（子菜单用 fuzzel 递归）"""
    parent = 0
    stack = []
    while True:
        nodes = menu_nodes(svc, menu_path, parent)
        if not nodes:
            notify(f"{title}: 无可用菜单项")
            return
        labels = []
        for _, label, enabled, has_child, depth in nodes:
            prefix = "  " * depth
            suffix = "  ▸" if has_child else ""
            flags = "" if enabled else "  (禁用)"
            labels.append(f"{prefix}{label}{suffix}{flags}")
        choice = fuzzel(title, labels)
        if choice is None:
            return
        idx = labels.index(choice)
        nid, label, enabled, has_child, _ = nodes[idx]
        if not enabled:
            notify(f"{label}（不可用）")
            continue
        if has_child:
            parent = nid
            stack.append(parent)
            title = label
            continue
        try:
            menu_event(svc, menu_path, nid)
        except Exception as e:
            notify(f"执行失败: {e}")
        return


def main():
    if "--list" in sys.argv:
        for it in list_items():
            print(f"  {it['title']:<20} {it['svc']:<10} {it['menu']}")
        return

    items = list_items()
    if not items:
        notify("托盘为空")
        return

    labels = []
    actions = []
    for it in items:
        if it["menu"]:
            labels.append(f"{it['title']}  →  菜单")
            actions.append(("menu", it))
        labels.append(f"{it['title']}  →  打开")
        actions.append(("open", it))

    choice = fuzzel("托盘", labels)
    if choice is None:
        return
    kind, it = actions[labels.index(choice)]

    if kind == "open":
        try:
            p = props(it["svc"], it["path"])
            o = BUS.get_object(it["svc"], it["path"])
            dbus.Interface(o, IFACE_SNI).Activate(dbus.Int32(0), dbus.Int32(0))
        except Exception as e:
            notify(f"打开失败: {e}")
        return

    pick_menu(it["svc"], it["menu"], it["title"])


if __name__ == "__main__":
    main()
