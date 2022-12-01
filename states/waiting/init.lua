local waitingState = gameclass:addState('waiting')

function waitingState:enteredState()
	updateWindowTitle('Waiting For Novel...')

	function love.directorydropped(path)
		gamepath = path
		love.directorydropped = nil
		self:gotoState('boot')
	end
end

function waitingState:draw()
	love.graphics.setFont(globalFont)
	love.graphics.setColor(colors.white)
	
	drawScreenCenteredText('Drop a directory containing a novel.')
end