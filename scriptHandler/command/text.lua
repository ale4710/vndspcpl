local TEXT_PREFIX_COMMAND_PATTERN = '[@~!]'
local TEXT_PREFIX_BLANK = '[~!]'

local TEXT_COLORED_PATTERN = '\\x1b%[([%d;]+)m'

return function(ci)
	local function processText(text)
		if(text) then
			text = variableHandler.convertVariables(text)
			local stop = true
			local blank = false

			local textFirstChar = text:sub(1,1)
			if(textFirstChar:find(TEXT_PREFIX_COMMAND_PATTERN)) then
				if(#text == 1) then
					if(textFirstChar:find(TEXT_PREFIX_BLANK)) then 
						blank = true
						if(textFirstChar == '~') then
							stop = false
						end
					end
				end
				
				if(textFirstChar == '@') then
					stop = false
				end
				
				text = text:sub(2)
			end
			
			local textTable = {type = 'text'}
			do
				local ttp = {}
				local last = 1
				while(last <= #text) do
					local start, stop, param = text:find(TEXT_COLORED_PATTERN, last)
					if(not start) then 
						table.insert(ttp, text:sub(last))
						break
					end
					
					if(start ~= 1) then 
						table.insert(ttp, text:sub(last, start - 1))
					end
					
					local color, mode = unpack(string.split(param, ';', true))
					
					--print(color, mode)
					
					color = tonumber(color)
					mode = mode and tonumber(mode)
					
					if((mode or color) == 0) then 
						color = 0
					end
					
					table.insert(ttp, color)
					
					last = stop + 1
				end
				
				do 
					local currentColor
					for _, value in ipairs(ttp) do 
						if(type(value) == 'number') then 
							currentColor = ((value ~= 0) and value) or nil
						else
							table.insert(textTable, {
								text = value,
								color = currentColor
							})
						end
					end
				end
				ttp = nil
			end
			
			return textTable, nil, nil, (stop or nil)
		end
	end

	return {text = processText}
end