# macro: $(ctype)
# Not a registered container: treat the name as a vanilla entity id (chest_minecart, hopper_minecart, ...).
$data modify storage guikit:ctx cdef set value {entity:"$(ctype)", slots:27, pad:"minecraft:gray_stained_glass_pane"}
