local mn = ...
local interface = {}

function interface.draw()
	--  list of variables
	do 
		local scale = userSettings.textScale * 0.7
		local variables = ''
		for key, value in pairs(variableHandler.variables) do 
			if(type(value) == 'string') then
				value = '"' .. value .. '"'
			end
			variables = key .. ': ' .. value .. ' // ' .. variables
		end
		love.graphics.setFont(globalFont)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(
			variables, 
			1, 1, 
			SCREEN.w / scale,
			'left',
			0, 
			scale
		 )
		love.graphics.setColor(1,1,1)
		love.graphics.printf(
			variables, 
			0, 0, 
			SCREEN.w / scale,
			'left',
			0, 
			scale
		 )
	end
end

return interface
