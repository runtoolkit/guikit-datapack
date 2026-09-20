# macro: $(menu)     as player, at player     (called by api/open)
# 1. container name comes from the registered menu, default chest_minecart
$data modify storage guikit:ctx ctype set from storage guikit:reg menus."$(menu)".container
execute unless data storage guikit:ctx ctype run data modify storage guikit:ctx ctype set value "chest_minecart"

# 2. resolve its definition: registry entry (guikit:reg containers.<name>, see containers_builtin),
#    otherwise the name is taken as a raw entity id like before (27 slots, gray pad)
data remove storage guikit:ctx cdef
function guikit:internal/summon/resolve with storage guikit:ctx
execute unless data storage guikit:ctx cdef run function guikit:internal/summon/legacy with storage guikit:ctx
execute unless data storage guikit:ctx cdef.entity run data modify storage guikit:ctx cdef.entity set from storage guikit:ctx ctype
execute unless data storage guikit:ctx cdef.slots run data modify storage guikit:ctx cdef.slots set value 27
execute unless data storage guikit:ctx cdef.pad run data modify storage guikit:ctx cdef.pad set value "minecraft:gray_stained_glass_pane"

# 3. summon (a title becomes the CustomName)
execute if data storage guikit:ctx cdef.title run function guikit:internal/summon/titled with storage guikit:ctx cdef
execute unless data storage guikit:ctx cdef.title run function guikit:internal/summon/type with storage guikit:ctx cdef

# 4. slot count on cart and owner; the definition is kept per owner uid for widget/pad
execute store result score @s guikit.slots run data get storage guikit:ctx cdef.slots
scoreboard players operation @e[type=#guikit:container,tag=guikit.new,distance=..1,limit=1] guikit.slots = @s guikit.slots
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
function guikit:internal/summon/bind with storage guikit:ctx
# a cart that looks different from the plain 27-slot gray one takes the registry-driven pad path
execute unless data storage guikit:ctx cdef{slots:27,pad:"minecraft:gray_stained_glass_pane"} run tag @e[type=#guikit:container,tag=guikit.new,distance=..1,limit=1] add guikit.styled

data remove storage guikit:ctx ctype
data remove storage guikit:ctx cdef
data remove storage guikit:ctx uid
