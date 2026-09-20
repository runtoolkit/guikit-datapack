# guikit :: internal/clear_mtr
# Clears the guikit:mtr scratch storage before a fresh defs lookup, so stale keys from a
# previous meter_draw / meter_probe call (obj, max, width, id, c, cur) can never leak into the
# next one. Same idea as internal/clear_in / internal/clear_w.
data remove storage guikit:mtr cur
data remove storage guikit:mtr obj
data remove storage guikit:mtr max
data remove storage guikit:mtr width
data remove storage guikit:mtr id
data remove storage guikit:mtr c
