--item.lua

local errorMsg = table.deepcopy(data.raw["flying-text"]["flying-text"])

errorMsg.name = "error-msg"
errorMsg.speed=.02
errorMsg.time_to_live=45
errorMsg.text_alignment="center"

data:extend{errorMsg}