# demo :: probe   (via #guikit:probe, as player). ONE line per clickable widget id.
execute unless entity @s[tag=guikit.m.demo_main] run return 0
data modify storage guikit:p {} set value {id:"buy_gem", fn:"demo:click/buy_gem"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"sound", fn:"demo:click/sound"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"volume_up", fn:"demo:click/volume_up"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"mode", fn:"demo:click/mode"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"prog_up", fn:"demo:click/prog_up"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"to_page1", fn:"demo:click/to_page1"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"to_page0", fn:"demo:click/to_page0"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"close", fn:"demo:click/close"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"lootbox", fn:"demo:click/lootbox"}
function guikit:widget/probe with storage guikit:p
data modify storage guikit:p {} set value {id:"danger", fn:"demo:click/danger"}
function guikit:widget/probe with storage guikit:p
