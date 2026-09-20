# guikit :: internal/btn/poor     as player     reads storage guikit:btn cur.poor
function guikit:internal/clear/in
data modify storage guikit:in msg set value "You can't afford that."
execute if data storage guikit:btn cur.poor run data modify storage guikit:in msg set from storage guikit:btn cur.poor
data modify storage guikit:in color set value "red"
function guikit:widget/say
