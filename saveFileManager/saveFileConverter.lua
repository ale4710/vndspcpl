local interface = {}

local function createVarNode(variables)
	local varnode = {
		tagName = 'variables',
		children = {}
	}
	for key, value in pairs(variables) do 
		if(value ~= 0) then 
			table.insert(
				varnode.children,
				{
					tagName = 'var',
					params = {
						name = key,
						value = value,
						type = ((type(value) == 'number') and 'int') or 'str'
					}
				}
			)
		end
	end
	
	return varnode
end

function interface.serialize(save)
	local varnode = createVarNode(save.variables)
	
	local sprnode = {
		tagName = 'sprites',
		children = {}
	}
	for _, sprite in ipairs(save.sprites) do 
		table.insert(
			sprnode.children,
			{
				tagName = 'sprite',
				params = {
					path = (FOLDER_FILE_NAMES[2] .. '/' .. sprite.path),
					x = sprite.x,
					y = sprite.y
				}
			}
		)
	end
	
	local date = os.date('%H:%M %Y/%m/%d')

	return xml.serialize({
		{tagName = 'save', children = {
			{tagName = 'script', children = {
				{tagName = 'file', innerText = (FOLDER_FILE_NAMES[3] .. '/' .. save.script)},
				{tagName = 'position', innerText = save.position}
			}},
			
			{tagName = 'date', innerText = date},
			
			varnode,
			
			{tagName = 'state', children = {
				{tagName = 'music', innerText = (FOLDER_FILE_NAMES[4] .. '/' .. save.music)},
				{tagName = 'background', innerText = (FOLDER_FILE_NAMES[1] .. '/' .. save.background)},
				sprnode
			}}
		}}
	})
end

do 
	local save
	local savexml
	local actions = {}
	--key of actions is node name
	
	actions['script'] = (function()
		local sa = {}
		sa['file'] = (function(node)
			save.script = node.innerText:sub(8)
		end)
		sa['position'] = (function(node)
			local n = tonumber(node.innerText)
			save.position = n and math.floor(n)
		end)
	
		return (function(mainNode)
			if(mainNode.children) then 
				for _, node in ipairs(mainNode.children) do 
					local safn = sa[node.tagName]
					if(safn) then 
						safn(node) 
					end
				end
			end
		end)
	end)()
	
	actions['date'] = (function(node)
		if(not save.date and node.innerText) then 
			local _, _, hour, minute, year, month, day = node.innerText:find('^(%d%d):(%d%d) (%d%d%d%d)/(%d%d)/(%d%d)$')
			if(hour) then 
				save.date = os.time({
					year = tonumber(year),
					month = tonumber(month),
					day = tonumber(day),
					hour = tonumber(hour),
					minute = tonumber(minute)
				})
			end
		end
	end)
	
	actions['variables'] = (function()
		local validTypes = {
			['int'] = tonumber,
			['str'] = true
		}
		return (function(mainNode)
			assert(not save.variables, 'multiple <variables> found in xml file.')
			
			save.variables = {}
			
			for _, node in ipairs(mainNode.children) do
				if(
					(node.tagName == 'var') and
					(node.params) and
					(node.params.name) and
					(node.params.type) and
					(node.params.value)
				) then
					local typeCheck = validTypes[node.params.type]
					local value = node.params.value
					if(typeCheck) then 
						if(type(typeCheck) == 'function') then 
							value = typeCheck(value)
						end

						save.variables[node.params.name] = value
					end
				end
			end
		end)
	end)()
	
	actions['state'] = (function()
		local sa = {}
		sa['music'] = (function(node)
			save.music = node.innerText and node.innerText:sub(7) --7 = length of 'sound/'
		end)
		sa['background'] = (function(node)
			save.background = node.innerText and node.innerText:sub(12) --12 = length of 'background/'
		end)
		sa['sprites'] = (function(mainNode) 
			assert(not save.sprites, 'multiple <sprites> found in xml file.')
			
			save.sprites = {}
			
			if(mainNode.children) then 
				for _, node in ipairs(mainNode.children) do 
					if(node.tagName == 'sprite') then 
						if(
							node.params and
							node.params.path and
							node.params.x and
							node.params.y
						) then 
							local x, y = tonumber(node.params.x), tonumber(node.params.y)
							
							if(x and y) then 
								table.insert(save.sprites, {
									path = node.params.path:sub(12), --length of 'foreground'
									x = math.floor(x),
									y = math.floor(y)
								})
							end
						end
					end
				end
			end
		end)
		
		return (function(mainNode)
			if(mainNode.children) then 
				for _, node in ipairs(mainNode.children) do 
					local safn = sa[node.tagName]
					if(safn) then 
						safn(node) 
					end
				end
			end
		end)

	end)()
	
	function interface.parse(savexmlstring)
		save = {}
		
		savexml = xml.parse(savexmlstring)
		savexmlstring = nil
		
		assert(savexml[1], 'xml is empty')
		assert((savexml[1].tagName == 'save'), 'xml has invalid namespace')
		assert(
			(
				(savexml[1].children) and 
				(#savexml[1].children > 0)
			),
			'xml save file has no content'
		)

		for _, node in ipairs(savexml[1].children) do
			local nodeAction = actions[node.tagName]
			if(nodeAction) then 
				nodeAction(node)
			end
		end
		
		savexml = nil
		local rs = save
		save = nil
		return rs
	end
end

function interface.serializeGlobal(variables)
	local varNode = createVarNode(variables)
	varNode.tagName = 'global'
	return xml.serialize({varNode})
end

function interface.parseGlobal(globalxmlstring)
	local variables = {}
	local gxml = xml.parse(globalxmlstring)
	for _, node in ipairs(gxml) do 
		if(node.tagName == 'global') then 
			for _, varnode in ipairs(node.children) do 
				if(
					(varnode.tagName == 'var') and
					(varnode.params) and
					(varnode.params.name) and
					(varnode.params.value) and
					(varnode.params.type)
				) then 
					local value = varnode.params.value
					if(varnode.params.type == 'int') then 
						value = tonumber(value)
						if(value == nil) then 
							goto continue
						end
					end
					
					variables[varnode.params.name] = value
				end
				
				::continue::
			end
			break
		end
	end
	
	return variables
end

return interface
