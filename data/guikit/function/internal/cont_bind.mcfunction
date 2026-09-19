# macro: $(uid)     as player
# Keeps the resolved container definition for this owner while the menu is open (widget/pad reads it).
$data modify storage guikit:cont bound.u$(uid) set from storage guikit:ctx cdef
