# guikit :: widget/radio   as player
# storage guikit:in {obj:"mode", value:2}
# Direct-assign generalization of widget/toggle for objectives with more than two states: each
# option in the group calls this with its own literal `value` (menu code decides which slot maps
# to which value, exactly like widget/toggle / widget/cycle -- no separate defs registry, unlike
# widget/button or widget/meter).
function guikit:internal/radio_set with storage guikit:in
scoreboard players set @s guikit.dirty 1
