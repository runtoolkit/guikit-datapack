# macro: $(id) $(slot)     as cart      (called by widget/draw_on_cart when `item replace` did not place the widget)
$tellraw @a[distance=..8] [{"text":"[guikit] could not draw widget ","color":"red"},{"text":"$(id)","color":"gold"},{"text":" in slot $(slot) (check name / lore / item)","color":"red"}]
