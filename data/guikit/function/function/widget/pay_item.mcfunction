# guikit :: widget/pay_item   as player   storage guikit:in {item:"minecraft:diamond", count:3}
# Result: 1 paid / 0 not enough
function guikit:internal/pay_item with storage guikit:in
return run scoreboard players get #paid guikit.tmp
