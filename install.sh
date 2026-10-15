#!/usr/bin/env bash
# Usage: ./install.sh [thumb_color] [track_color] [auto|thin|none]
# Override the profile with: PROFILE=/path/to/profile ./install.sh
set -euo pipefail
COLOR="${1:-#7e62b8}"; TRACK="${2:-#80808033}"; WIDTH="${3:-auto}"

case "$(uname -s)" in
  Darwin) ROOTS=("$HOME/Library/Application Support/zen") ;;
  *)      ROOTS=("${XDG_CONFIG_HOME:-$HOME/.config}/zen" "$HOME/.zen"
                 "$HOME/.var/app/app.zen_browser.zen/config/zen" "$HOME/.var/app/app.zen_browser.zen/.zen") ;;
esac

# Profile in use, per profiles.ini: [Install*] Default=, else the [Profile*] with Default=1.
find_profile() {
  local root ini path
  for root in "${ROOTS[@]}"; do
    ini="$root/profiles.ini"
    [ -f "$ini" ] || continue
    path="$(awk -F= '
      { sub(/\r$/, "") }
      /^\[/ { sec=$0; next }
      sec ~ /^\[Install/ && $1=="Default" && !inst { inst=$2 }
      sec ~ /^\[Profile/ && $1=="Path"      { p[sec]=$2 }
      sec ~ /^\[Profile/ && $1=="Default" && $2=="1" { d=sec }
      END { print (inst ? inst : p[d]) }' "$ini")"
    [ -n "$path" ] || continue
    case "$path" in /*) ;; *) path="$root/$path" ;; esac
    [ -d "$path" ] && { echo "$path"; return; }
  done
}
PROFILE="${PROFILE:-$(find_profile)}"
[ -n "$PROFILE" ] || { echo "Profile not found. Set PROFILE=... (about:support > Profile Folder)." >&2; exit 1; }
echo "Profile: $PROFILE"

mkdir -p "$PROFILE/chrome"
CSS="$PROFILE/chrome/userContent.css"
[ -f "$CSS" ] && cp "$CSS" "$CSS.bak"

cat > "$CSS" <<EOF
:root {
  --zsc-thumb: $COLOR;
  --zsc-track: $TRACK;
  --zsc-width: $WIDTH;
}
* {
  scrollbar-color: var(--zsc-thumb) var(--zsc-track) !important;
  scrollbar-width: var(--zsc-width) !important;
}
EOF

grep -qs 'legacyUserProfileCustomizations' "$PROFILE/user.js" \
  || echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$PROFILE/user.js"
echo "Done. Restart Zen completely."