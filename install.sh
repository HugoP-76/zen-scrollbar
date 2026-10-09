#!/usr/bin/env bash
# Usage: ./install.sh [thumb_color] [track_color] [auto|thin|none]
# Override the profile with: PROFILE=/path/to/profile ./install.sh
set -euo pipefail
COLOR="${1:-#7e62b8}"; TRACK="${2:-#80808033}"; WIDTH="${3:-auto}"

case "$(uname -s)" in
  Darwin) ROOT="$HOME/Library/Application Support/zen" ;;
  *)      ROOT="$HOME/.zen" ;;
esac
PROFILE="${PROFILE:-$(find "$ROOT" -maxdepth 2 -type d -name '*Default*' | head -n1)}"
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