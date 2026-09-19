# guikit :: internal/sweep_orphans      (run on load; also safe to run manually)
# A cart whose owner logged off / died / lost its uid would live forever. Mark every cart,
# unmark the ones that still have an owner with the same uid, dispose the rest.
tag @e[type=#guikit:container,tag=guikit.cart] add guikit.orphan
execute as @a[scores={guikit.uid=1..}] run function guikit:internal/sweep_keep
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.orphan] run function guikit:internal/dispose_cart
