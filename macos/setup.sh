#!/bin/sh
# macOS system settings that stow cannot cover. Idempotent, run any time:
#   sh macos/setup.sh        (or: just setup_macos)
set -eu

echo "Keyboard modifier mapping (System Settings > Keyboard > Keyboard Shortcuts... > Modifier Keys)"
# The block below is generated. To refresh it after changing the mapping in
# System Settings run:  macos/keyboard-modifier-mapping backup
# >>> keyboard-modifier-mapping >>>
# Gaming KB (vendor 9610 / product 428)
#     Caps Lock -> Globe (Fn)
defaults -currentHost write -g com.apple.keyboard.modifiermapping.9610-428-0 -array \
  '<dict><key>HIDKeyboardModifierMappingDst</key><integer>1095216660483</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'
# <<< keyboard-modifier-mapping <<<
echo "  applied. Replug the keyboard or log out and in for it to take effect."
