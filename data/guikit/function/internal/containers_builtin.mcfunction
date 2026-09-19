# guikit :: internal/containers_builtin      (called from core/load BEFORE #guikit:register)
# Built-in entries of the container registry, storage guikit:reg containers.<name>:
#   entity  vanilla entity id WITHOUT namespace; it must be in the entity type tag #guikit:container
#   slots   inventory size (27 chest_minecart, 5 hopper_minecart)          default 27
#   pad     item id used by widget/pad to fill every slot                    default minecraft:gray_stained_glass_pane
#   title   optional SNBT text component shown as the container title, e.g. {text:"Barrel"}
# Menu packs add or replace entries from #guikit:register (this runs first, so they win).
# Every "themed" preset is still a chest_minecart / hopper_minecart underneath: only entities can be
# summoned and filled with `item replace entity`, and Minecraft has no ender chest / barrel entity.
data modify storage guikit:reg containers set value {}
data modify storage guikit:reg containers.chest_minecart set value {entity:"chest_minecart", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.hopper_minecart set value {entity:"hopper_minecart", slots:5, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.ender_chest set value {entity:"chest_minecart", slots:27, pad:"minecraft:purple_stained_glass_pane", title:{text:"Ender Chest"}}
data modify storage guikit:reg containers.barrel set value {entity:"chest_minecart", slots:27, pad:"minecraft:brown_stained_glass_pane", title:{text:"Barrel"}}
data modify storage guikit:reg containers.trapped_chest set value {entity:"chest_minecart", slots:27, pad:"minecraft:red_stained_glass_pane", title:{text:"Trapped Chest"}}
data modify storage guikit:reg containers.shulker_box set value {entity:"chest_minecart", slots:27, pad:"minecraft:magenta_stained_glass_pane", title:{text:"Shulker Box"}}
data modify storage guikit:reg containers.copper_chest set value {entity:"chest_minecart", slots:27, pad:"minecraft:orange_stained_glass_pane", title:{text:"Copper Chest"}}
