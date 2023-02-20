local interface = {}

local function assertVolume(volume) 
	assert(type(volume) == 'number', 'Volume must be number.')
	assert(
		(
			(volume <= 1) and
			(volume >= 0)
		),
		'Volume out of bounds. Must be within [0,1]'
	)
end

--bgm
local currentBgm
local bgmVolume = 1
function interface.setBgmVolume(volume)
	assertVolume(volume)
	bgmVolume = volume
	if(currentBgm) then 
		currentBgm:setVolume(bgmVolume)
	end
end
function interface.getBgmVolume() return bgmVolume end
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
		currentBgm:setVolume(bgmVolume)
		currentBgm:play()
	end
end

--sfx
local playingSfx = {}
local sfxVolume = 1
function interface.setSfxVolume(volume) 
	assertVolume(volume)
	sfxVolume = volume
	for _, sfx in pairs(playingSfx) do 
		if(not sfx.done) then 
			sfx.src:setVolume(sfxVolume)
		end
	end
end
function interface.getSfxVolume() return sfxVolume end

local sfxClass = class('sfxClass')
function sfxClass:initialize(src, loops)
	print('[soundHandler] play sound, playing ' .. (loops or 1) .. ' time(s)')
	self.loops = loops or 1
	if(self.loops ~= 0) then
		self.src = src:clone()
		if(self.loops == -1) then
			self.loops = true
			self.src:setLooping(true)
			self.src:play()
		end
		self.src:setVolume(sfxVolume)
		self.loopsPassed = 0
		table.insert(playingSfx, self)
	end
end
function sfxClass:check()
	--this excludes infinite looping sounds.
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
	if(self.loops == true) then
		return true
	elseif(self.done) then
		return 1
	else
		local duration = self.src:getDuration()
		return (self.src:tell() + ((self.loopsPassed - 1) * duration)) / (duration * self.loops)
	end
end

function interface.playSfx(src, loopAmount)
	if(userSettings.disableSounds) then return end
	if(src and userSettings.oneSoundEffectOnly) then
		interface.playSfx() --stop all
	end
	
	if(src) then
		--stop any infinite looping sounds
		for _, playingSrc in pairs(playingSfx) do
			if(playingSrc.loops == true) then 
				playingSrc:stop()
			end
		end
		
		sfxClass:new(src, loopAmount)
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
		for _, snd in ipairs(playingSfx) do
			local progress = snd:getProgress()
			if(progress) then 
				table.insert(progs, progress)
			end
		end
		if(#progs ~= 0) then 
			return progs
		end
	end
end

function interface.update()
	do 
		local index = 1
		while(index <= #playingSfx) do
			local src = playingSfx[index]
			if(src.done) then 
				table.remove(playingSfx, index)
			else
				src:check()
				index = index + 1
			end
		end
	end
end

return interface
