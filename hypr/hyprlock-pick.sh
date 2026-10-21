#!/bin/sh
# =============================================================================
# hyprlock-pick.sh — switch between the styles collected in
#                   ~/.config/hypr/hyprlock-styles/
#
# usage:
#   hyprlock-pick.sh              # list every available style, mark the active one
#   hyprlock-pick.sh <prefix>     # copy <prefix>*.conf over hyprlock.conf
#
# examples:
#   hyprlock-pick.sh vivek-style-3     # exact-ish (prefix) match
#   hyprlock-pick.sh end4
#   hyprlock-pick.sh a3
#
# The change is picked up the next time hyprlock starts (i.e. next lock).
# It does NOT lock the screen, so your session stays usable.
# =============================================================================

STYLE_DIR="$HOME/.config/hypr/hyprlock-styles"
TARGET="$HOME/.config/hypr/hyprlock.conf"

if [ ! -d "$STYLE_DIR" ]; then
    echo "error: $STYLE_DIR not found" >&2
    exit 1
fi

list_styles() {
    printf 'available styles in %s:\n\n' "$STYLE_DIR"
    for f in "$STYLE_DIR"/*.conf; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        if [ -f "$TARGET" ] && cmp -s "$f" "$TARGET"; then
            mark="   <== ACTIVE"
        else
            mark=""
        fi
        printf '  %-24s%s\n' "$name" "$mark"
    done
}

case "$1" in
"" | -l | --list | list)
    list_styles
    printf '\nusage: %s <name prefix>\n' "$(basename "$0")"
    exit 0
    ;;
-h | --help | help)
    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
esac

want=$(basename "$1" .conf)

# exact filename match first
if [ -f "$STYLE_DIR/$want.conf" ]; then
    n=1
    match="$STYLE_DIR/$want.conf"
else
    matches=$(for f in "$STYLE_DIR/$want"*.conf; do [ -f "$f" ] && printf '%s\n' "$f"; done)
    n=$(printf '%s\n' "$matches" | grep -c .)
    match=$(printf '%s\n' "$matches" | head -n 1)
fi

if [ "$n" -eq 0 ]; then
    echo "error: no style matches '$1'" >&2
    echo >&2
    list_styles >&2
    exit 1
fi

if [ "$n" -gt 1 ]; then
    echo "error: '$1' is ambiguous, $n styles match:" >&2
    printf '%s\n' "$matches" | while IFS= read -r m; do
        [ -n "$m" ] && printf '  %s\n' "$(basename "$m")" >&2
    done
    exit 1
fi

cp -- "$match" "$TARGET" || exit 1
printf 'applied: %s\n' "$(basename "$match")"
printf 'target : %s\n' "$TARGET"
printf 'note   : takes effect the next time the screen locks (hyprlock is not started here).\n'
