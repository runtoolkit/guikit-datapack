# demo :: theme/ender_chest_fill   as player   (menu demo:ender_chest_demo, container:"ender_chest")
# Built-in registry preset: purple pad + "Ender Chest" title (README "Container types").
function guikit:widget/pad

function guikit:internal/clear/w
data merge storage guikit:w {slot:13, item:"minecraft:ender_eye", id:"label", type:"info", name:{text:"Ender Chest theme",color:"light_purple",italic:false}, lore:[{text:"27 slots, a chest_minecart with a purple pad",color:"gray",italic:false}]}
function guikit:widget/draw

function guikit:internal/clear/w
data merge storage guikit:w {slot:22, item:"minecraft:arrow", id:"back", type:"nav", name:{text:"Back",color:"white",italic:false}, lore:[]}
function guikit:widget/draw

function guikit:internal/clear/w
data merge storage guikit:w {slot:26, item:"minecraft:barrier", id:"close", type:"close", name:{text:"Close",color:"red",italic:false}, lore:[]}
function guikit:widget/draw
