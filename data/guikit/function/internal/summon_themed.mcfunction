# guikit :: internal/summon_themed
# macro: $(theme) $(name)
# Minecraft has no `ender_chest` or `barrel` ENTITY (only the blocks) -- the framework's whole
# mechanic depends on `/summon minecraft:<ctype>` + `item replace entity @s container.N`, and
# only entities can be summoned/targeted that way. So a themed container still summons the real
# chest_minecart (27 slots -- matches both real containers' inventory size 1:1) and is tagged
# + named so pad/draw can style it to look the part. NOT verified in a live 26.3 client yet
# (see README "Validation status") -- CustomName may or may not change the minecart's GUI title;
# if it doesn't, the entity is still functionally correct, just titled "Minecart with Chest".
$summon minecraft:chest_minecart ~ ~ ~ {Invulnerable:1b,NoGravity:1b,Silent:1b,CustomName:'$(name)',CustomNameVisible:0b,Tags:["guikit.cart","guikit.new","guikit.theme.$(theme)"]}
