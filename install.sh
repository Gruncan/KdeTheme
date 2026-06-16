#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing Matte Black KDE theme..."

# --- SDDM theme ---
echo "  Installing SDDM theme..."
sudo cp -r "$SCRIPT_DIR/sddm/matte-black" /usr/share/sddm/themes/

# Copy wallpaper into SDDM theme directory
WALLPAPER="$HOME/.local/share/omarchy/themes/matte-black/backgrounds/2-dot-hands.jpg"
if [ -f "$WALLPAPER" ]; then
    sudo cp "$WALLPAPER" /usr/share/sddm/themes/matte-black/
else
    echo "  WARNING: Could not find 2-dot-hands.jpg at $WALLPAPER"
    echo "           Copy it manually: sudo cp /path/to/2-dot-hands.jpg /usr/share/sddm/themes/matte-black/"
fi

# Activate SDDM theme
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/matte-black.conf > /dev/null <<'EOF'
[Theme]
Current=matte-black
EOF
echo "  SDDM theme activated."

# --- KDE colour scheme ---
echo "  Installing KDE colour scheme..."
mkdir -p "$HOME/.local/share/color-schemes"
cp "$SCRIPT_DIR/color-scheme/MatteBlack.colors" "$HOME/.local/share/color-schemes/"
echo "  Apply in: System Settings → Appearance → Colors → Matte Black"

# --- KDE look-and-feel (KScreenLocker) ---
echo "  Installing look-and-feel package..."
mkdir -p "$HOME/.local/share/plasma/look-and-feel"
cp -r "$SCRIPT_DIR/look-and-feel/com.omarchy.matteblack" "$HOME/.local/share/plasma/look-and-feel/"

# Copy wallpaper into look-and-feel images dir
if [ -f "$WALLPAPER" ]; then
    cp "$WALLPAPER" "$HOME/.local/share/plasma/look-and-feel/com.omarchy.matteblack/contents/images/"
else
    echo "  WARNING: Copy 2-dot-hands.jpg to:"
    echo "           ~/.local/share/plasma/look-and-feel/com.omarchy.matteblack/contents/images/"
fi
echo "  Apply in: System Settings → Workspace Behavior → Screen Locking → Appearance → Matte Black"

echo ""
echo "Done. Log out and back in to see the SDDM theme."
echo "Apply the colour scheme and lock screen theme in System Settings."
