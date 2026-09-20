# guikit :: widget/button    as player
# storage guikit:w = {slot, item, id, name, lore}      (same keys as widget/draw; type is set to "button")
#
# Draws a button whose behaviour lives in a definition (see widget/button_probe for the click side):
#   data modify storage guikit:btn defs."ns:id" set value {cmd:"...", ...}      <- in your #guikit:register listener
#
# If the definition has a `cond` and it fails right now, the item is swapped for `locked_item`
# (default minecraft:barrier). The click handler re-checks the condition, so the look is cosmetic only.
data modify storage guikit:w type set value "button"
function guikit:internal/btn/visual with storage guikit:w
function guikit:widget/draw
