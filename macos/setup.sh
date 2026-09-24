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

echo "Cycle windows of the front app with Cmd+^ (System Settings > Keyboard > Keyboard Shortcuts... > Keyboard > Move focus to next window)"
# Symbolic hotkey 27, parameters are (character, virtual keycode, modifiers).
# The default is keycode 50, which on ISO keyboards is the < key next to left
# Shift (Cmd+<). Keycode 10 is the key left of 1, ^ on the German layout.
# 1048576 = Command. Cmd+Shift+^ cycles backwards.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 27 \
  '<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>94</integer><integer>10</integer><integer>1048576</integer></array></dict></dict>'
# Reload symbolic hotkeys so the change applies without logging out.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
echo "  applied."
