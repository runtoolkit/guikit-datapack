# guikit :: internal/clear_in
# `data merge` keeps old keys, and `data remove storage X` needs a path, so the
# scratch storage is cleared key by key. Call this BEFORE `data merge storage guikit:in {...}`
# so keys from a previous widget call (wrap, min, max, delta, ...) can never leak.
data remove storage guikit:in color
data remove storage guikit:in count
data remove storage guikit:in delta
data remove storage guikit:in item
data remove storage guikit:in last
data remove storage guikit:in max
data remove storage guikit:in menu
data remove storage guikit:in min
data remove storage guikit:in msg
data remove storage guikit:in n
data remove storage guikit:in obj
data remove storage guikit:in page
data remove storage guikit:in ticks
data remove storage guikit:in timer
data remove storage guikit:in value
data remove storage guikit:in wrap
