# demo :: internal/buy_sword     run by the "demo:sword" button (as player); the button already
# checked demo.coins >= 5 via its cond.
scoreboard players remove @s demo.coins 5
give @s minecraft:iron_sword 1
