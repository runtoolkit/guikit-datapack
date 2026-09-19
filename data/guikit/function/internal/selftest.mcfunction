# guikit :: internal/selftest     /execute as @s run function guikit:internal/selftest
# Verifies in a REAL game that `clear @s *[custom_data~{guikit:{w:1b}}]` only matches widget items.
# Gives a normal stick, counts; then gives a marked stick, counts. Expected: 0 then 1.
# Uses count-only (`... 0`) so it never deletes anything. Removes its own test items at the end.
give @s minecraft:stick[custom_data={guikit_selftest:1b}] 1
execute store result score #st_plain guikit.tmp run clear @s *[custom_data~{guikit:{w:1b}}] 0
give @s minecraft:stick[custom_data={guikit:{w:1b,id:"selftest"}}] 1
execute store result score #st_marked guikit.tmp run clear @s *[custom_data~{guikit:{w:1b}}] 0
clear @s minecraft:stick[custom_data~{guikit_selftest:1b}]
clear @s minecraft:stick[custom_data~{guikit:{id:"selftest"}}]
execute if score #st_plain guikit.tmp matches 0 if score #st_marked guikit.tmp matches 1 run tellraw @s {"text":"[guikit selftest] PASS - widget filter works","color":"green"}
execute unless score #st_plain guikit.tmp matches 0 run tellraw @s {"text":"[guikit selftest] FAIL - filter matches NON-widget items (clear would wipe inventory)","color":"red"}
execute if score #st_plain guikit.tmp matches 0 unless score #st_marked guikit.tmp matches 1 run tellraw @s {"text":"[guikit selftest] FAIL - filter does not match widget items","color":"red"}
scoreboard players reset #st_plain guikit.tmp
scoreboard players reset #st_marked guikit.tmp
