# guikit :: internal/clear_tmp
# Transient storage that is NOT covered by clear_in / clear_w / clear_cond.
# NOTE: guikit:reg (menu registry) and guikit:btn defs are PERMANENT (rebuilt on load) - never touched here.
# guikit:btn cur is NOT cleared here on purpose: api/close can run from INSIDE btn_click
# (button cmd "function guikit:api/close"), which still reads `cur` afterwards.
# It is cleared at the end of btn_click and on load (see internal/clear_btn_cur).
data remove storage guikit:ctx menu
data remove storage guikit:ctx alias
data remove storage guikit:ctx ctype
data remove storage guikit:p id
