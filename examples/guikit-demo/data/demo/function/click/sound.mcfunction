function guikit:internal/clear_in
data merge storage guikit:in {obj:"demo.sound_on"}
function guikit:widget/toggle
# guikit:widget/sound (ui category, audible to this player only). Needs `at @s`: the probe runs it that way.
execute if score @s demo.sound_on matches 1 run function demo:internal/click_pling
