# guikit :: internal/summon/builtin      (called from core/load BEFORE #guikit:register)
# Built-in entries of the container registry, storage guikit:reg containers.<name>:
#   entity  vanilla entity id WITHOUT namespace; it must be in the entity type tag #guikit:container
#   slots   inventory size (27 chest_minecart/chest_boat, 5 hopper_minecart, 15 donkey/mule) default 27
#   pad     item id used by widget/pad to fill every slot                    default minecraft:gray_stained_glass_pane
#   title   optional SNBT text component shown as the container title, e.g. {text:"Barrel"}
#   (there is NO `offset` key: every entity used so far addresses its slots as container.0 .. container.slots-1.)
# donkey/mule are registered for later but are deliberately NOT in data/guikit/tags/entity_type/container.json:
# their Items[] is reported (minecraft.wiki) as Slot 2..16 (saddle=0, chest-flag=1) and how `container.N` maps
# onto that is unconfirmed against a live 26.3 client (README "Validation status"). Because they are outside the
# tag, api/open refuses them through internal/open_fail. Supporting them would need an offset in pad_slot and
# widget/draw_on_cart.
# Menu packs add or replace entries from #guikit:register (this runs first, so they win).
# Every "themed" chest/barrel/etc preset is still a chest_minecart underneath: only entities can
# be summoned and filled with `item replace entity`, and Minecraft has no ender chest / barrel
# entity.
data modify storage guikit:reg containers set value {}
data modify storage guikit:reg containers.chest_minecart set value {entity:"chest_minecart", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.hopper_minecart set value {entity:"hopper_minecart", slots:5, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.ender_chest set value {entity:"chest_minecart", slots:27, pad:"minecraft:purple_stained_glass_pane", title:{text:"Ender Chest"}}
data modify storage guikit:reg containers.barrel set value {entity:"chest_minecart", slots:27, pad:"minecraft:brown_stained_glass_pane", title:{text:"Barrel"}}
data modify storage guikit:reg containers.trapped_chest set value {entity:"chest_minecart", slots:27, pad:"minecraft:red_stained_glass_pane", title:{text:"Trapped Chest"}}
data modify storage guikit:reg containers.shulker_box set value {entity:"chest_minecart", slots:27, pad:"minecraft:magenta_stained_glass_pane", title:{text:"Shulker Box"}}
data modify storage guikit:reg containers.copper_chest set value {entity:"chest_minecart", slots:27, pad:"minecraft:orange_stained_glass_pane", title:{text:"Copper Chest"}}

# chest boats: same 27-slot Items[] layout as chest_minecart, offset 0, one registry entry per
# wood type (split into separate entity ids since data pack version 55 / 24w39a, confirmed
# present at pack_format 121 / 26.3). pale_oak_chest_boat / poplar_chest_boat exist per the wiki
# but their introducing version wasn't confirmed against this pack_format -- NOT added; add them
# the same way once confirmed.
data modify storage guikit:reg containers.oak_chest_boat set value {entity:"oak_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.spruce_chest_boat set value {entity:"spruce_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.birch_chest_boat set value {entity:"birch_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.jungle_chest_boat set value {entity:"jungle_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.acacia_chest_boat set value {entity:"acacia_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.dark_oak_chest_boat set value {entity:"dark_oak_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.mangrove_chest_boat set value {entity:"mangrove_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.cherry_chest_boat set value {entity:"cherry_chest_boat", slots:27, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.bamboo_chest_raft set value {entity:"bamboo_chest_raft", slots:27, pad:"minecraft:gray_stained_glass_pane"}

# donkey/mule: registered for later, see the note above: not in #guikit:container, so api/open
# refuses them (internal/open_fail) until the container.N mapping is confirmed live.
data modify storage guikit:reg containers.donkey set value {entity:"donkey", slots:15, pad:"minecraft:gray_stained_glass_pane"}
data modify storage guikit:reg containers.mule set value {entity:"mule", slots:15, pad:"minecraft:gray_stained_glass_pane"}
