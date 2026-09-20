# macro: $(entity) $(title)     (storage guikit:ctx cdef; title is an SNBT text component, expanded as SNBT)
# NOT NBT-string JSON: in 26.3 CustomName:'{"text":"x"}' is a plain string and would show the JSON itself.
$summon minecraft:$(entity) ~ ~ ~ {Invulnerable:1b,NoGravity:1b,Silent:1b,Enabled:0b,CustomName:$(title),CustomNameVisible:0b,Tags:["guikit.cart","guikit.new"]}
