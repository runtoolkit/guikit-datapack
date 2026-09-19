# macro: $(ctype)
# Leaves storage guikit:ctx cdef unset when the name is not in the registry.
$data modify storage guikit:ctx cdef set from storage guikit:reg containers."$(ctype)"
