# guikit :: internal/btn_afford     as player     reads storage guikit:btn cur.cost
#   cost:{obj:"coins", amount:5}                    score cost
#   cost:{item:"minecraft:diamond", [count:3]}      item cost (count defaults to 1)
# Result in #cond guikit.tmp (1 = enough). Does not charge.
scoreboard players set #cond guikit.tmp 1
execute unless data storage guikit:btn cur.cost.count run data modify storage guikit:btn cur.cost.count set value 1
execute if data storage guikit:btn cur.cost.obj run function guikit:internal/btn_afford_score with storage guikit:btn cur.cost
execute if data storage guikit:btn cur.cost.item run function guikit:internal/btn_afford_item
