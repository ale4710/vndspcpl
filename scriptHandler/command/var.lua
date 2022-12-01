local vars = variableHandler.variables

local ARITHMETIC_MODIFIER_PATTERN = '[%+%-]'

--local VARIABLE_SET_PATTERN = '^ *$?([%a%d_]+) *([%=%+%-%~]) *("?.+"?) *$'
local VARIABLE_SET_PATTERN = '^ *$?([^ ]+) *([%=%+%-%~]) *("?.+"?) *$'

local modifierFns = {
	['+'] = (function(a, b)
		return a + b
	end),
	
	['-'] = (function(a, b)
		return a - b
	end),
	
	['='] = (function(_, b)
		return b
	end)
}

return function(ci)
	local cmds = {}
	
	local function generalSetVar(args)
		--args = variableHandler.convertVariables(args)
		if(args) then
		
			local _, _, name, modifier, value = args:find(VARIABLE_SET_PATTERN)
			
			if(name) then
				local existingVariable = vars[name]
				
				if(modifier == '~') then
					vars[name] = nil
					return nil, name, existingVariable, modifier, nil
				else
					--see if it is a variable somehow
					do 
						local valueev = vars[value]
						if(valueev) then 
							value = valueev
							goto checkFinish
						end
					end
					
					--test if string
					do 
						local _, _, valuenq = string.find(value, STRING_PATTERN)
						if(valuenq) then 
							value = variableHandler.convertVariables(valuenq)
							goto checkFinish
						end
					end
					
					--test if number
					value = tonumber(value) or value
					
					::checkFinish::
					
					--check if modifier is for numbers only
					if(
						string.find(modifier, ARITHMETIC_MODIFIER_PATTERN)
					) then 
						if(
							((type(existingVariable) == 'number') or (not existingVariable)) and
							(type(value) == 'number')
						) then 
							--it's all cool
							if(existingVariable == nil) then 
								existingVariable = 0
							end
						else
							print('[scriptHandler/var] malformed setvar')
							return
						end
					end
					
					local mfn = modifierFns[modifier]
					if(mfn) then
						local result = mfn(existingVariable, value)
						vars[name] = result
						print('[scriptHandler/var] ' .. name .. ' is now ' .. result)
						return result, name, existingVariable, modifier, value
					else
						return
					end
				end
			elseif(args:find('^ *~ ~ *$')) then
				variableHandler.reset()
			end
		end
	end
	
	do 
		local function setvar(...) 
			generalSetVar(...) 
		end
		
		cmds['setvar'] = setvar
		cmds['var'] = setvar --vnds2 spec
	end
	
	do 
		local function gsetvar(...)
			local result, name = generalSetVar(...)
			if(name) then 
				variableHandler.global.variables[name] = result
				return nil, nil, nil, nil, true
			end
		end
		
		cmds['gsetvar'] = gsetvar
		cmds['gvar'] = gsetvar
	end
	
	return cmds
end