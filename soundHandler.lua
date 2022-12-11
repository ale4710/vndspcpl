local interface = {}

--bgm
local currentBgm
function interface.changeBgm(src)
	if(userSettings.disableSounds) then return end
	print(
		(src and 'bgm updated') or
		'bgm stopped'
	)
	if(currentBgm) then 
		currentBgm:stop() 
		currentBgm:release()
		currentBgm = nil
	end
	if(src) then 
		currentBgm = src:clone()
		currentBgm:setLooping(true)
		currentBgm:play()
	end
end

--sfx
local playingSfx = {}

local sfxClass = class('sfxClass')
function sfxClass:initialize(src, loops) 
	self.loops = loops or 1
	if(self.loops ~= 0) then
		self.src = src:clone()
		if(self.loops == -1) then
			self.loops = true
			self.src:setLooping(true) 
		end
		self.loopsPassed = 0
		table.insert(playingSfx, self)
	end
end
function sfxClass:check()
	if(
		(not self.done) and
		(not self.src:isPlaying()) and
		(not self.src:isLooping())
	) then 
		if(self.loops == self.loopsPassed) then 
			self:stop()
		else
			self.src:play()
		end
		self.loopsPassed = self.loopsPassed + 1
	end
end
function sfxClass:stop()
	if(not self.done) then 
		self.src:stop()
		self.src:release()
		self.src = nil
		self.done = true
	end
end
function sfxClass:isPlaying()
	return self.src:isPlaying() or (self.loopsPassed < self.loops)
end
function sfxClass:getProgress()
	if(
		(self.loops ~= true) and
		(not self.done)
	) then 
		local duration = self.snd:getDuration()
		return (self.snd:tell() + (self.loopsPassed * duration)) / (duration * self.loops)
	end
end

function interface.playSfx(src, loopAmount)
	if(userSettings.disableSounds) then return end
	if(src and userSettings.oneSoundEffectOnly) then
		interface.playSfx()
	end
	
	if(src) then
		print('[soundHandler] play a sound')
		sfxClass:new(src, loopAmount)
		--stop any infinite looping sounds
		for _, playingSrc in pairs(playingSfx) do
			if(playingSrc.loops == true) then 
				playingSrc:stop()
			end
		end
	else
		--empty means stop everything
		print('[soundHandler] stopped all sound effects')
		for _, playingSrc in pairs(playingSfx) do
			playingSrc:stop()
		end
	end
end

function interface.getSfxProgress()
	if(#playingSfx ~= 0) then 
		local progs = {}
		for _, snd in pairs(playingSfx) do 
			table.insert(progs, snd:getProgress())
		end
		return progs
	end
end

function interface.update()
	for k, src in pairs(playingSfx) do
		src:check()
		if(src.done) then
			playingSfx[k] = nil
		end
	end
end

return interface
