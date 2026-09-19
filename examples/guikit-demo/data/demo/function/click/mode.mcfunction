# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
function guikit:internal/clear_in
data merge storage guikit:in {obj:"demo.mode", n:3, last:2, wrap:1b}
function guikit:widget/cycle
