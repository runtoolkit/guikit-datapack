# guikit :: internal/cleanup_player   as player (called from api/close)
# Wipes per-session scratch storage so nothing from this menu leaks into the next one.
#
# guikit:in is deliberately NOT cleared here: api/open calls api/close in the middle of its own
# run (to close a previous menu) and still needs guikit:in {menu,page,timer} afterwards.
# The caller owns guikit:in (see internal/clear_in, called before every `data merge storage guikit:in`).
function guikit:internal/clear/w
function guikit:internal/clear/cond
function guikit:internal/clear/tmp
function guikit:internal/clear/mtr
