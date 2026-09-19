# demo :: main/fill      as player.  Pad everything first, then draw widgets on top.
function guikit:widget/pad
execute if score @s guikit.page matches 0 run function demo:main/page0
execute if score @s guikit.page matches 1 run function demo:main/page1
execute if score @s guikit.page matches 2 run function demo:main/page2
