# demo :: theme/ender_chest_fill   as player   (menu demo:ender_chest_demo, container:"ender_chest")
# Shows the themed preset in action -- see README "Container types". Purple pad comes from
# widget/pad picking widget/pad_cart_ender_chest for a guikit.theme.ender_chest-tagged cart.
function guikit:widget/pad
function guikit:internal/clear_w
data merge storage guikit:w {slot:13, item:"minecraft:ender_eye", id:"label", type:"info", name:'{"text":"Ender Chest theme","color":"light_purple","italic":false}', lore:'[{"text":"27 slots, same chest_minecart under the hood","color":"gray","italic":false},{"text":"see README \"Container types\"","color":"dark_gray","italic":false}]'}
function guikit:widget/draw
function guikit:internal/clear_w
data merge storage guikit:w {slot:22, item:"minecraft:arrow", id:"back", type:"nav", name:'{"text":"Back","color":"white","italic":false}', lore:'[]'}
function guikit:widget/draw
function guikit:internal/clear_w
data merge storage guikit:w {slot:26, item:"minecraft:barrier", id:"close", type:"close", name:'{"text":"Close","color":"red","italic":false}', lore:'[]'}
function guikit:widget/draw
