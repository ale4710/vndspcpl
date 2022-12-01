--[[
	ｘ WARNING ｘ WARNING ｘ WARNING ｘ
	this xml thing only supports the most basic xml stuff.
	additionally, the parser can and probably will break very easily.
	do not use for anything where reliable xml parsing/encoding is needed.
]]

--[[ example...
		(xml)
	<list>
		<character>
			<name>Sakuya</name>
			<sex>F</sex>
			<relation>
				<character name="Remilia" type="boss" />
			</relation>
		</character>
	</list>

		(lua)
	{
		{
			name = 'list',
			children = {
				{
					name = 'character',
					children = {
						{
							name = 'name',
							innerText = 'Sakuya'
						},
						{
							name = 'sex',
							innerText = 'F'
						},
						{
							name = 'relation',
							children = {
								{
									name = 'character',
									params = {
										name = 'Remilia',
										type = 'boss'
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
		(lua -> xml) (actual output)
	<list>
		<character>
			<name>Sakuya</name>
			<sex>F</sex>
			<relation>
				<character type="boss" name="Remilia" />
			</relation>
		</character>
	</list>
]]

local interface = {}

local TAG_PATTERN = '< -(/?) -([^>]+) ->'

local TAG_PARAM_PRE_PATTERN = '([%d%a]*[%d%a])'
local TAG_PARAM_VALUE_PATTERN = '="([^"]-)"'

local escape
do 
	local needToEscape = {
		['<'] = 'lt',
		['>'] = 'gt',
		['&'] = 'amp',
		['"'] = 'quot'
	}
	
	escape = (function(str)
		for index = 1, #str, 1 do 
			local char = str:sub(index, index)
			local escaped = needToEscape[char]
			
			if(escaped) then 
				local before = (index > 0 and str:sub(1, index - 1)) or ''
				local after  = (index < #str and str:sub(index + 1, #str)) or ''
				str = before .. escaped .. after
			end
		end
		return str
	end)
end

local unescape
do 
	local ESCAPE_SEQUENCE_PATTERN = '&(#?[%d%a]+);'
	
	if(utf8) then 
		local shortcuts = {
			['amp'] = '&',
			['lt'] = '<',
			['gt'] = '>',
			['quot'] = '"',
			['apos'] = '\'',
			['nbsp'] = utf8.char(160),
			['cent'] = utf8.char(162),
			['pound'] = utf8.char(163),
			['yen'] = utf8.char(165),
			['euro'] = utf8.char(8364),
			['copy'] = utf8.char(169),
			['reg'] = utf8.char(174)
		}
		
		local function r(code)
			if(code:sub(1,1) == '#') then 
				local coden = tonumber(code:sub(2))
				if(coden) then 
					return utf8.char(coden)
				end
			end
			
			return shortcuts[code] or '?'
		end
		
		unescape = (function(str)
			return str:gsub(ESCAPE_SEQUENCE_PATTERN, r)
		end)
	else
		unescape = (function(str) return str end)
	end
end

local function getLatestNode(tree)
	return tree[#tree]
end
function interface.parse(str)
	local root = {}
	local tree = {root}
	local last = 1
	
	while(true) do 
		local tagStart, tagEnd, tagOpen, tagContents, tagAutoClose = str:find(TAG_PATTERN, last)
		
		if(not tagStart) then break end
		
		if(
			( --checking (ignoring) <?xml version="666"?>
				str:sub(tagStart + 1, tagStart + 1) == '?' and
				str:sub(tagEnd - 1, tagEnd - 1) == '?'
			)
		) then 
			goto continue
		end
		
		tagOpen = (tagOpen ~= '/')
		tagAutoClose = (tagContents:sub(#tagContents, #tagContents) == '/')
		if(tagAutoClose) then 
			tagContents = tagContents:sub(1, #tagContents - 1)
		end
		
		do
			local latestNode = getLatestNode(tree)
			
			if(tagOpen) then
				local node = {
					tagName = nil,
					children = {},
					params = {}
				}
				
				table.insert(
					(latestNode and latestNode.children) or latestNode,
					node
				)
				
				table.insert(tree, node)
				
				local tagNameEnd = tagContents:find(' ')
				if(tagNameEnd) then
					node.tagName = tagContents:sub(1, tagNameEnd - 1)
					
					local ss, se = tagContents:find(' *')
					if(ss == 1) then 
						tagContents = tagContents:sub(se + 1)
					end
				else
					node.tagName = tagContents
					goto finish
				end
				
				do 
					local paramLast = 1
					while(true) do 
						local _, paramNameEnd, paramName = tagContents:find(TAG_PARAM_PRE_PATTERN, paramLast)
						if(paramNameEnd) then
							local paramContentsStart, paramContentsEnd, paramContents = tagContents:find(TAG_PARAM_VALUE_PATTERN, paramNameEnd + 1)
							if(
								(not paramContents) or
								(paramContentsStart ~= paramNameEnd + 1)
							) then
								paramContents = ''
								paramContentsStart = nil
								paramContentsEnd = nil
							end
							
							node.params[paramName] = unescape(paramContents)
							paramLast = (paramContentsEnd or paramNameEnd) + 1
						else
							break
						end
					end
				end
				
				::finish::
			end
			
			if(tagAutoClose) then
				table.remove(tree)
			elseif(not tagOpen) then
				if(latestNode and latestNode.tagName == tagContents) then
					if(
						latestNode.children and 
						#latestNode.children == 0
					) then 
						latestNode.children = nil
					end
					
					latestNode.innerText = unescape(str:sub(last + 1, tagStart - 1))
					
					table.remove(tree)
				else
					print('[xml/parser] unexpected close.')
				end
			end
		end
		
		::continue::
		
		last = tagEnd
	end
	
	return root
end

local function serializeTraverse(inNode)
	local sstr = ''
	if(inNode) then 
		sstr = '<' .. inNode.tagName .. ' '
		
		if(inNode.params) then 
			for key, value in pairs(inNode.params) do 
				sstr = sstr .. key .. '="' .. escape(tostring(value)) .. '" '
			end
		end
		
		local innerText = inNode.innerText and tostring(inNode.innerText)
		
		local autoClose = (
			(
				not inNode.children or
				#inNode.children == 0
			) and (
				not innerText or
				#innerText == 0
			)
		)
		
		if(autoClose) then 
			sstr = sstr .. '/'
		else
			--remove extra space
			sstr = sstr:sub(1, #sstr - 1)
		end
		
		sstr = sstr .. '>'

		if(not autoClose) then 
			if(inNode.children) then
				for _, node in ipairs(inNode.children) do 
					sstr = sstr .. serializeTraverse(node)
				end
			else
				sstr = sstr .. escape(innerText or '')
			end

			sstr = sstr .. '</' .. inNode.tagName .. '>'
		end
	end

	return sstr
end
function interface.serialize(root) 
	local fstr = ''
	for _, node in ipairs(root) do 
		fstr = fstr .. serializeTraverse(node)
	end
	return fstr
end

return interface