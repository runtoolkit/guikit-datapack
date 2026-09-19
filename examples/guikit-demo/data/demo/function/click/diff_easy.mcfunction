# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
function guikit:internal/clear_in
data merge storage guikit:in {obj:"demo.difficulty", value:0}
function guikit:widget/radio
